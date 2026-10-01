/**
 * お試し期間の終了前通知。
 *
 * notifyTrialExpiring: 毎日9時(JST)に、お試し中の会社の管理者へ、終了の3日前・1日前・当日に
 * プッシュ通知を送る。同じ日の通知は会社ドキュメントの trialNoticesSent に記録し、
 * Schedulerの再実行などで二重に送らない。
 */

import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";

const DAY_MS = 24 * 60 * 60 * 1000;
const JST_OFFSET_MS = 9 * 60 * 60 * 1000;

/** 通知を送る「終了までの日数」。 */
export const TRIAL_NOTICE_DAYS = [3, 1, 0] as const;

const jstDateOnlyMs = (d: Date): number => {
  const j = new Date(d.getTime() + JST_OFFSET_MS);
  return Date.UTC(j.getUTCFullYear(), j.getUTCMonth(), j.getUTCDate());
};

/**
 * 今日がお試し終了の何日前かを返す(JSTの暦日で比較)。
 * 通知対象の日(3・1・0日前)でなければnull。
 */
export function trialNoticeDay(trialEndsAt: Date, now: Date): number | null {
  const days = Math.round((jstDateOnlyMs(trialEndsAt) - jstDateOnlyMs(now)) / DAY_MS);
  return (TRIAL_NOTICE_DAYS as readonly number[]).includes(days) ? days : null;
}

export function trialNoticeMessage(daysLeft: number): { title: string; body: string } {
  const when = daysLeft === 0 ? "本日" : `あと${daysLeft}日`;
  return {
    title: "お試し期間の終了について",
    body:
      `Safyのお試し期間は${when}で終了します。継続して使うには、` +
      "アプリの「ご契約について」から契約方法をご確認ください。登録済みのメンバーや受講記録は消えません。",
  };
}

export const notifyTrialExpiring = onSchedule(
  { schedule: "every day 09:00", timeZone: "Asia/Tokyo" },
  async () => {
    const db = admin.firestore();
    const now = new Date();
    const trials = await db.collection("companies").where("planType", "==", "trial").get();

    for (const companyDoc of trials.docs) {
      const data = companyDoc.data() as {
        trialEndsAt?: admin.firestore.Timestamp;
        trialNoticesSent?: number[];
      };
      if (!data.trialEndsAt) continue;
      const day = trialNoticeDay(data.trialEndsAt.toDate(), now);
      if (day === null) continue;
      if ((data.trialNoticesSent ?? []).includes(day)) continue;

      const admins = await db
        .collection(`companies/${companyDoc.id}/employees`)
        .where("role", "==", "admin")
        .get();
      const { title, body } = trialNoticeMessage(day);

      let sent = 0;
      for (const adminDoc of admins.docs) {
        const token = adminDoc.data().fcmToken as string | undefined;
        if (!token) continue;
        try {
          await admin.messaging().send({ token, notification: { title, body } });
          sent++;
        } catch (error) {
          logger.warn(`お試し終了通知の送信に失敗 companyId=${companyDoc.id} employeeId=${adminDoc.id}`, error);
        }
      }
      // 1通も送れなかった場合(トークン未登録など)は記録せず、翌日以降の対象日に再挑戦させる。
      if (sent > 0) {
        await companyDoc.ref.update({
          trialNoticesSent: admin.firestore.FieldValue.arrayUnion(day),
        });
      }
    }
  },
);
