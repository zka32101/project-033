/**
 * 安心企業研修Safy Cloud Functions
 *
 * 前提: Firebase Console本設定・`firebase deploy --only functions`実行後に有効化される。
 * ローカルではflutter analyze/testの対象外(Node.js/TypeScript側は別途 `npm run build` で検証)。
 *
 * 実装済み関数:
 *   - submitQuizAttempt: クイズ採点・監査証跡書き込み(QuizService.submitAttemptから呼ばれる)
 *   - onReminderCreated: 管理者の個別リマインド送信をトリガーにプッシュ通知を送る
 *   - checkModuleDeadlinesAndNotify: 受講期限が近い/過ぎた社員に毎日プッシュ通知する(定期実行)
 *   - sendMonthlyReports: 前月分の履修状況レポートをcontactEmail宛に毎月1日送信する(定期実行)
 *     ※SendGrid経由で直接送信する。デプロイ前に以下のSecretを設定すること:
 *       firebase functions:secrets:set SENDGRID_API_KEY
 *       firebase functions:secrets:set SENDGRID_FROM_EMAIL  (SendGridで送信元認証済みのアドレス)
 *     (Firebase Extensions「Trigger Email」は2027-03-31に廃止予定のため採用しない)
 */

import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import sgMail from "@sendgrid/mail";

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

const sendgridApiKey = defineSecret("SENDGRID_API_KEY");
const sendgridFromEmail = defineSecret("SENDGRID_FROM_EMAIL");

// ─────────────────────────────────────────────
// 型(Flutter側のモデルと対応。Cloud Functions側は緩めのバリデーションに留める)
// ─────────────────────────────────────────────
interface QuizQuestionDoc {
  correctIndex: number;
}

interface CompanyDoc {
  name?: string;
  customPassThreshold?: Record<string, number>;
  moduleDeadlines?: Record<string, admin.firestore.Timestamp>;
  contractedHeadcount?: number;
  contactEmail?: string;
}

interface ModuleDoc {
  passThresholdDefault?: number;
}

interface EmployeeDoc {
  fcmToken?: string;
  displayName?: string;
}

// ─────────────────────────────────────────────
// submitQuizAttempt: クイズ採点・QuizAttempt/CompletionCertificate書き込み
// 改ざん防止のためクライアントから直接書き込ませず、ここで正式なスコアを再計算する。
// ─────────────────────────────────────────────
export const submitQuizAttempt = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "サインインが必要です");
  }

  const { companyId, employeeId, moduleId, selectedAnswers } = request.data as {
    companyId?: string;
    employeeId?: string;
    moduleId?: string;
    selectedAnswers?: number[];
  };

  if (!companyId || !employeeId || !moduleId || !Array.isArray(selectedAnswers)) {
    throw new HttpsError("invalid-argument", "companyId/employeeId/moduleId/selectedAnswersが必要です");
  }
  // Employeeドキュメント名は必ずauth.uidと一致させる方式(EmployeeService参照)なので、
  // 他人になりすましてクイズ結果を書き込めないようにここで検証する。
  if (auth.uid !== employeeId) {
    throw new HttpsError("permission-denied", "本人以外のクイズ結果は送信できません");
  }

  const [companySnap, moduleSnap, questionsSnap] = await Promise.all([
    db.doc(`companies/${companyId}`).get(),
    db.doc(`modules/${moduleId}`).get(),
    db.collection(`modules/${moduleId}/quizQuestions`).get(),
  ]);

  if (!companySnap.exists) {
    throw new HttpsError("not-found", "会社情報が見つかりません");
  }
  if (questionsSnap.empty) {
    throw new HttpsError("failed-precondition", "この研修にはまだクイズ問題が登録されていません");
  }

  const company = companySnap.data() as CompanyDoc;
  const module = (moduleSnap.data() as ModuleDoc | undefined) ?? {};
  const correctIndexes = questionsSnap.docs.map(
    (d) => (d.data() as QuizQuestionDoc).correctIndex
  );

  const correctCount = correctIndexes.reduce(
    (count, correct, i) => (selectedAnswers[i] === correct ? count + 1 : count),
    0
  );
  const score = Math.round((correctCount / correctIndexes.length) * 100);
  const thresholdApplied =
    company.customPassThreshold?.[moduleId] ?? module.passThresholdDefault ?? 80;
  const passed = score >= thresholdApplied;
  const answeredAt = admin.firestore.FieldValue.serverTimestamp();

  const attemptRef = db.collection(`companies/${companyId}/quizAttempts`).doc();
  await attemptRef.set({
    employeeId,
    moduleId,
    score,
    passed,
    thresholdApplied,
    selectedAnswers,
    answeredAt,
  });

  if (passed) {
    const certificateRef = db.collection(`companies/${companyId}/certificates`).doc();
    await certificateRef.set({
      employeeId,
      companyId,
      moduleId,
      score,
      thresholdApplied,
      issuedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // callableの戻り値はJSONとしてシリアライズされるため、answeredAtはミリ秒数値で返す
  // (Flutter側QuizAttempt.fromMapのparseFirestoreDateTimeがnum/Timestamp両対応)。
  return {
    attemptId: attemptRef.id,
    employeeId,
    moduleId,
    score,
    passed,
    thresholdApplied,
    selectedAnswers,
    answeredAt: Date.now(),
  };
});

// ─────────────────────────────────────────────
// onReminderCreated: 管理者の個別リマインド送信(ReminderService.sendReminder)を
// トリガーにプッシュ通知を送る。
// ─────────────────────────────────────────────
export const onReminderCreated = onDocumentCreated(
  "companies/{companyId}/reminders/{reminderId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const { companyId } = event.params;
    const { employeeId } = snapshot.data() as { employeeId?: string };
    if (!employeeId) return;

    const employeeSnap = await db.doc(`companies/${companyId}/employees/${employeeId}`).get();
    const employee = employeeSnap.data() as EmployeeDoc | undefined;
    if (!employee?.fcmToken) {
      logger.info(`fcmToken未登録のためリマインド通知をスキップ: ${employeeId}`);
      return;
    }

    await messaging.send({
      token: employee.fcmToken,
      notification: {
        title: "研修のリマインド",
        body: "未受講の研修があります。安心企業研修Safyでご確認ください。",
      },
    });
  }
);

// ─────────────────────────────────────────────
// checkModuleDeadlinesAndNotify: 受講期限が近い(3日以内)/過ぎた社員に毎日通知する。
// Firebase Console設定完了後、Cloud Schedulerが自動的にこの関数を毎日呼び出す。
// ─────────────────────────────────────────────
const REMINDER_WINDOW_DAYS = 3;

export const checkModuleDeadlinesAndNotify = onSchedule(
  { schedule: "every day 09:00", timeZone: "Asia/Tokyo" },
  async () => {
    const companiesSnap = await db.collection("companies").get();

    for (const companyDoc of companiesSnap.docs) {
      const company = companyDoc.data() as CompanyDoc;
      const deadlines = company.moduleDeadlines ?? {};
      if (Object.keys(deadlines).length === 0) continue;

      const companyId = companyDoc.id;
      const [employeesSnap, enrollmentsSnap] = await Promise.all([
        db.collection(`companies/${companyId}/employees`).get(),
        db.collection(`companies/${companyId}/enrollments`).get(),
      ]);

      const completedByEmployeeModule = new Set(
        enrollmentsSnap.docs
          .filter((d) => d.data().status === "completed")
          .map((d) => `${d.data().employeeId}_${d.data().moduleId}`)
      );

      for (const [moduleId, dueDateTimestamp] of Object.entries(deadlines)) {
        const dueDate = dueDateTimestamp.toDate();
        const daysRemaining = Math.floor(
          (dueDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24)
        );
        // リマインド期間より先、または大幅に過ぎた古い期限は対象外(通知の送りすぎを防ぐ)
        if (daysRemaining > REMINDER_WINDOW_DAYS || daysRemaining < -30) continue;

        const statusLabel = daysRemaining < 0 ? "期限を過ぎています" : "期限が近づいています";

        for (const employeeDoc of employeesSnap.docs) {
          const employee = employeeDoc.data() as EmployeeDoc;
          if (!employee.fcmToken) continue;
          if (completedByEmployeeModule.has(`${employeeDoc.id}_${moduleId}`)) continue;

          try {
            await messaging.send({
              token: employee.fcmToken,
              notification: {
                title: "受講期限のお知らせ",
                body: `未受講の研修があります。${statusLabel}。安心企業研修Safyでご確認ください。`,
              },
            });
          } catch (error) {
            logger.warn(`通知送信に失敗しました employeeId=${employeeDoc.id}`, error);
          }
        }
      }
    }
  }
);

// ─────────────────────────────────────────────
// sendMonthlyReports: 毎月1日9時(JST)に、contactEmailを設定している会社へ
// 前月分の履修状況レポートをSendGrid経由で直接メール送信する。
// ─────────────────────────────────────────────
export const sendMonthlyReports = onSchedule(
  {
    schedule: "1 of month 09:00",
    timeZone: "Asia/Tokyo",
    secrets: [sendgridApiKey, sendgridFromEmail],
  },
  async () => {
    sgMail.setApiKey(sendgridApiKey.value());
    const fromEmail = sendgridFromEmail.value();

    const companiesSnap = await db.collection("companies").get();

    for (const companyDoc of companiesSnap.docs) {
      const company = companyDoc.data() as CompanyDoc;
      const contactEmail = company.contactEmail?.trim();
      if (!contactEmail) continue;

      const companyId = companyDoc.id;
      const [employeesSnap, enrollmentsSnap] = await Promise.all([
        db.collection(`companies/${companyId}/employees`).get(),
        db.collection(`companies/${companyId}/enrollments`).get(),
      ]);

      const totalEmployees = employeesSnap.size;
      const completedByEmployee = new Map<string, number>();
      for (const doc of enrollmentsSnap.docs) {
        const data = doc.data();
        if (data.status !== "completed") continue;
        const employeeId = data.employeeId as string;
        completedByEmployee.set(employeeId, (completedByEmployee.get(employeeId) ?? 0) + 1);
      }
      const employeesWithProgress = completedByEmployee.size;

      const now = new Date();
      const reportMonthLabel = `${now.getFullYear()}年${now.getMonth() + 1}月`;

      try {
        await sgMail.send({
          to: contactEmail,
          from: fromEmail,
          subject: `【安心企業研修Safy】${reportMonthLabel} 履修状況レポート`,
          text:
            `${company.name ?? ""} 様\n\n` +
            `${reportMonthLabel}時点の履修状況をお知らせします。\n\n` +
            `対象社員数: ${totalEmployees}名\n` +
            `1件以上の研修を完了した社員数: ${employeesWithProgress}名\n\n` +
            `詳細はアプリの「レポート出力」画面からPDF/CSVでご確認いただけます。\n\n` +
            `安心企業研修Safy`,
        });
      } catch (error) {
        logger.warn(`月次レポートメール送信に失敗しました companyId=${companyId}`, error);
      }
    }
  }
);
