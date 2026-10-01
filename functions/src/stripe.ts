/**
 * Stripe連携(法人の請求書払い・カード決済)。
 *
 * 関数:
 *   - createCheckoutSession: 管理者がStripe Checkout(定額サブスク)を開始するURLを作る
 *   - createBillingPortalSession: 契約中の管理者が請求書の閲覧・支払い方法の変更・解約をするURLを作る
 *   - stripeWebhook: Stripeからの通知を受け、契約状態(会社ドキュメントとsubscriptions)を更新する
 *
 * 契約状態の正本は companies/{id}/subscriptions/company_{id}(アプリのアクセス判定が参照する)。
 * Webhookだけがここを書き換える(Admin SDK)。
 *
 * デプロイ前に以下のSecretを設定すること:
 *   firebase functions:secrets:set STRIPE_SECRET_KEY
 *   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
 *   firebase functions:secrets:set STRIPE_PRICE_ID   (1人あたり月額のPrice ID)
 * 戻り先URLは環境変数 BILLING_RETURN_URL(functions/.env)で指定する。
 */

import * as admin from "firebase-admin";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { defineSecret, defineString } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import Stripe from "stripe";

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const stripePriceId = defineSecret("STRIPE_PRICE_ID");
const billingReturnUrl = defineString("BILLING_RETURN_URL", { default: "" });

const MAX_SEATS = 1000;
const ACTIVE_STATUSES = new Set(["active", "trialing", "past_due"]);

const getDb = () => admin.firestore();

/** 呼び出し者が、指定した会社の管理者であることを検証して会社データを返す。 */
async function requireCompanyAdmin(uid: string | undefined, companyId: unknown) {
  if (!uid) throw new HttpsError("unauthenticated", "サインインが必要です");
  if (typeof companyId !== "string" || !companyId) {
    throw new HttpsError("invalid-argument", "companyIdが必要です");
  }
  const db = getDb();
  const employee = (await db.doc(`companies/${companyId}/employees/${uid}`).get()).data() as
    | { role?: string }
    | undefined;
  if (employee?.role !== "admin") {
    throw new HttpsError("permission-denied", "この会社の管理者のみ実行できます");
  }
  const companySnap = await db.doc(`companies/${companyId}`).get();
  if (!companySnap.exists) throw new HttpsError("not-found", "会社情報が見つかりません");
  return { companyRef: companySnap.ref, company: companySnap.data() as Record<string, unknown> };
}

function returnUrlOrThrow(): string {
  const url = billingReturnUrl.value();
  if (!url) {
    throw new HttpsError("failed-precondition", "決済の戻り先URLが未設定です(BILLING_RETURN_URL)");
  }
  return url;
}

export const createCheckoutSession = onCall(
  { secrets: [stripeSecretKey, stripePriceId] },
  async (request) => {
    const { companyId, seats } = request.data as { companyId?: string; seats?: number };
    const { companyRef, company } = await requireCompanyAdmin(request.auth?.uid, companyId);

    if (company.billingSource === "invoice" || company.billingSource === "store") {
      throw new HttpsError("failed-precondition", "すでに有料契約があります");
    }
    if (!Number.isInteger(seats) || (seats as number) < 1 || (seats as number) > MAX_SEATS) {
      throw new HttpsError("invalid-argument", `人数は1〜${MAX_SEATS}の整数で指定してください`);
    }
    // 現在のメンバー数より少ない人数では契約できない(参加済みの人が使えなくなるため)。
    const memberCount = (await companyRef.collection("employees").count().get()).data().count;
    if ((seats as number) < memberCount) {
      throw new HttpsError("failed-precondition", `現在のメンバー数(${memberCount}名)以上で指定してください`);
    }

    const stripe = new Stripe(stripeSecretKey.value());
    let customerId = company.stripeCustomerId as string | undefined;
    if (!customerId) {
      const customer = await stripe.customers.create({
        name: (company.name as string) || undefined,
        metadata: { companyId: companyId as string },
      });
      customerId = customer.id;
      await companyRef.update({ stripeCustomerId: customerId });
    }

    const base = returnUrlOrThrow();
    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      client_reference_id: companyId,
      line_items: [{ price: stripePriceId.value(), quantity: seats }],
      billing_address_collection: "required",
      tax_id_collection: { enabled: true },
      customer_update: { name: "auto", address: "auto" },
      subscription_data: { metadata: { companyId: companyId as string } },
      success_url: `${base}?checkout=success`,
      cancel_url: `${base}?checkout=cancel`,
    });
    return { url: session.url };
  },
);

export const createBillingPortalSession = onCall({ secrets: [stripeSecretKey] }, async (request) => {
  const { companyId } = request.data as { companyId?: string };
  const { company } = await requireCompanyAdmin(request.auth?.uid, companyId);
  const customerId = company.stripeCustomerId as string | undefined;
  if (!customerId) throw new HttpsError("failed-precondition", "契約情報がありません");

  const stripe = new Stripe(stripeSecretKey.value());
  const session = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: returnUrlOrThrow(),
  });
  return { url: session.url };
});

/** Stripeのサブスクリプション状態を、会社ドキュメントとsubscriptionsに反映する。 */
async function applySubscription(sub: Stripe.Subscription): Promise<void> {
  const companyId = sub.metadata?.companyId;
  if (!companyId) {
    logger.warn("Stripe subscription without companyId metadata", { id: sub.id });
    return;
  }
  const db = getDb();
  const companyRef = db.doc(`companies/${companyId}`);
  if (!(await companyRef.get()).exists) {
    logger.warn("Stripe subscription for unknown company", { id: sub.id, companyId });
    return;
  }
  const subRef = db.doc(`companies/${companyId}/subscriptions/company_${companyId}`);
  const seats = sub.items.data.reduce((n, i) => n + (i.quantity ?? 0), 0) || 1;
  const periodEndSec =
    (sub as unknown as { current_period_end?: number }).current_period_end ??
    (sub.items.data[0] as unknown as { current_period_end?: number } | undefined)?.current_period_end;
  const now = admin.firestore.Timestamp.now();

  if (ACTIVE_STATUSES.has(sub.status)) {
    // past_dueは猶予として、当該期間の終了日までは利用を止めない。
    await subRef.set(
      {
        ownerType: "company",
        ownerId: companyId,
        subscribedModuleIds: [],
        fullSet: true,
        headcount: seats,
        status: "active",
        planTier: "upper",
        premiumTier: "none",
        startedAt: admin.firestore.Timestamp.fromMillis(sub.start_date * 1000),
        expiresAt: periodEndSec ? admin.firestore.Timestamp.fromMillis(periodEndSec * 1000) : null,
      },
      { merge: true },
    );
    await companyRef.update({
      planType: "team",
      billingSource: "invoice",
      contractedHeadcount: seats,
      stripeSubscriptionId: sub.id,
      stripeStatus: sub.status,
      trialEndsAt: admin.firestore.FieldValue.delete(),
    });
  } else {
    // 解約・未払い確定・期限切れ: 利用を止め、お試し終了と同じ状態(契約案内画面)に戻す。
    await subRef.set({ status: "expired", expiresAt: now }, { merge: true });
    await companyRef.update({
      planType: "trial",
      billingSource: "none",
      stripeStatus: sub.status,
      trialEndsAt: now,
    });
  }
}

export const stripeWebhook = onRequest(
  { secrets: [stripeSecretKey, stripeWebhookSecret] },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }
    const stripe = new Stripe(stripeSecretKey.value());
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        req.headers["stripe-signature"] as string,
        stripeWebhookSecret.value(),
      );
    } catch (e) {
      logger.warn("Stripe webhook signature verification failed", e);
      res.status(400).send("Invalid signature");
      return;
    }

    // 同じイベントの再送で二重処理しない(create()は既存なら失敗する)。
    const eventRef = getDb().doc(`stripeEvents/${event.id}`);
    try {
      await eventRef.create({ type: event.type, receivedAt: admin.firestore.Timestamp.now() });
    } catch {
      res.status(200).send("duplicate");
      return;
    }

    try {
      switch (event.type) {
        case "checkout.session.completed": {
          const session = event.data.object as Stripe.Checkout.Session;
          if (session.mode === "subscription" && typeof session.subscription === "string") {
            await applySubscription(await stripe.subscriptions.retrieve(session.subscription));
          }
          break;
        }
        case "customer.subscription.created":
        case "customer.subscription.updated":
        case "customer.subscription.deleted":
          await applySubscription(event.data.object as Stripe.Subscription);
          break;
        default:
          break;
      }
      res.status(200).send("ok");
    } catch (e) {
      // 失敗時はStripeに再送させるため、重複防止の記録を消して500を返す。
      logger.error("Stripe webhook handling failed", { type: event.type, error: e });
      await eventRef.delete().catch(() => undefined);
      res.status(500).send("error");
    }
  },
);
