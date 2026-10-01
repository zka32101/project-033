/**
 * 監査ログ(管理者の操作履歴)。
 *
 * メンバー・会社設定・チームの変更をFirestoreのトリガーで検知し、companies/{id}/auditLogs に
 * 「誰が・いつ・何をしたか」を記録する。書き込みはこの関数(Admin SDK)だけで、
 * クライアントからは書けない(firestore.rules)ので、管理者でも履歴を改ざんできない。
 *
 * 文面の組み立ては純粋関数(describe*)に分け、テストできるようにしている。
 */

import * as admin from "firebase-admin";
import { onDocumentWrittenWithAuthContext } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

type Data = Record<string, unknown> | undefined;

export interface AuditEntry {
  /** 操作の種類(絞り込み・集計用)。例: member.role_changed */
  action: string;
  /** 画面に表示する日本語の説明。 */
  summary: string;
  /** 対象の種類: member / company / team */
  targetType: "member" | "company" | "team";
  targetId: string;
}

const str = (v: unknown): string => (typeof v === "string" ? v : "");

/** 値の比較(Timestampなども含めて、JSON表現が同じなら同じとみなす)。 */
function sameValue(a: unknown, b: unknown): boolean {
  const norm = (v: unknown): string =>
    JSON.stringify(v, (_k, val) => {
      if (val && typeof val === "object" && !Array.isArray(val)) {
        return Object.keys(val as object)
          .sort()
          .reduce((acc: Record<string, unknown>, key) => {
            acc[key] = (val as Record<string, unknown>)[key];
            return acc;
          }, {});
      }
      return val;
    }) ?? "";
  return norm(a) === norm(b);
}

const countOf = (v: unknown): number => (Array.isArray(v) ? v.length : 0);

/** メンバー(employees)の変更。参加・削除・役割・無効化を記録する(表示名や通知トークンの更新は記録しない)。 */
export function describeEmployeeChange(before: Data, after: Data, employeeId: string): AuditEntry[] {
  const entry = (action: string, summary: string): AuditEntry => ({
    action,
    summary,
    targetType: "member",
    targetId: employeeId,
  });

  if (!before && after) {
    return [entry("member.joined", `${str(after.displayName) || "メンバー"}さんが参加しました`)];
  }
  if (before && !after) {
    return [entry("member.removed", `${str(before.displayName) || "メンバー"}さんがメンバーから削除されました`)];
  }
  if (!before || !after) return [];

  const name = str(after.displayName) || str(before.displayName) || "メンバー";
  const entries: AuditEntry[] = [];
  if (before.role !== after.role) {
    entries.push(
      after.role === "admin"
        ? entry("member.promoted", `${name}さんを管理者にしました`)
        : entry("member.demoted", `${name}さんを管理者からメンバーに戻しました`),
    );
  }
  const wasDeactivated = before.deactivated === true;
  const isDeactivated = after.deactivated === true;
  if (!wasDeactivated && isDeactivated) {
    entries.push(entry("member.deactivated", `${name}さんを無効化しました`));
  } else if (wasDeactivated && !isDeactivated) {
    entries.push(entry("member.reactivated", `${name}さんを再有効化しました`));
  }
  return entries;
}

/** 会社設定(companies)の変更。変更した項目だけを記録する(連絡先メールなどの値そのものは記録しない)。 */
export function describeCompanyChange(before: Data, after: Data, companyId: string): AuditEntry[] {
  if (!before || !after) return [];
  const entry = (action: string, summary: string): AuditEntry => ({
    action,
    summary,
    targetType: "company",
    targetId: companyId,
  });
  const changed = (key: string) => !sameValue(before[key], after[key]);
  const entries: AuditEntry[] = [];

  if (changed("profile")) {
    entries.push(entry("company.profile_changed", "会社情報(従業員数・事業の特徴)を変更しました"));
  }
  if (changed("assignedModuleIds")) {
    entries.push(
      entry("company.assignment_changed", `全社共通の必須研修を変更しました(${countOf(after.assignedModuleIds)}件)`),
    );
  }
  if (changed("categoryPriorityOverride")) {
    entries.push(entry("company.priority_changed", "業種プロファイル(重点分野)の調整を変更しました"));
  }
  if (changed("customPassThreshold")) {
    entries.push(entry("company.threshold_changed", "合格ラインを変更しました"));
  }
  if (changed("moduleDeadlines")) {
    entries.push(entry("company.deadline_changed", "受講期限を変更しました"));
  }
  if (changed("contactEmail")) {
    entries.push(entry("company.report_email_changed", "月次レポートの送付先を変更しました"));
  }
  if (changed("planType") || changed("billingSource")) {
    entries.push(entry("company.contract_changed", "契約の状態が更新されました"));
  }
  return entries;
}

/** チーム(teams)の変更。作成・削除・追加の必須研修・招待コードの発行を記録する。 */
export function describeTeamChange(before: Data, after: Data, teamId: string): AuditEntry[] {
  const entry = (action: string, summary: string): AuditEntry => ({
    action,
    summary,
    targetType: "team",
    targetId: teamId,
  });
  if (!before && after) {
    return [entry("team.created", `チーム「${str(after.teamName)}」を作成しました`)];
  }
  if (before && !after) {
    return [entry("team.deleted", `チーム「${str(before.teamName)}」を削除しました`)];
  }
  if (!before || !after) return [];

  const name = str(after.teamName) || str(before.teamName);
  const entries: AuditEntry[] = [];
  if (!sameValue(before.assignedModuleIds, after.assignedModuleIds)) {
    entries.push(
      entry(
        "team.assignment_changed",
        `チーム「${name}」の追加の必須研修を変更しました(${countOf(after.assignedModuleIds)}件)`,
      ),
    );
  }
  if (!str(before.inviteCode) && str(after.inviteCode)) {
    entries.push(entry("invite.issued", `チーム「${name}」の招待コードを発行しました`));
  }
  if (before.teamName !== after.teamName && str(before.teamName)) {
    entries.push(entry("team.renamed", `チーム名を「${str(before.teamName)}」から「${name}」に変更しました`));
  }
  return entries;
}

/** 操作した人の識別。アプリの利用者(Firebase Auth)ならそのuid、サーバー(関数)による変更ならnull。 */
export function actorOf(authType: string | undefined, authId: string | undefined): string | null {
  if (!authId) return null;
  if (authType === "service_account" || authType === "system" || authType === "api_key") return null;
  return authId;
}

async function writeEntries(
  companyId: string,
  authType: string | undefined,
  authId: string | undefined,
  entries: AuditEntry[],
): Promise<void> {
  if (entries.length === 0) return;
  const db = admin.firestore();
  const actorId = actorOf(authType, authId);
  let actorName = "システム";
  if (actorId) {
    const actor = await db.doc(`companies/${companyId}/employees/${actorId}`).get();
    actorName = str(actor.data()?.displayName) || "不明な利用者";
  }
  const batch = db.batch();
  const at = admin.firestore.Timestamp.now();
  for (const e of entries) {
    batch.set(db.collection(`companies/${companyId}/auditLogs`).doc(), {
      at,
      actorId: actorId ?? "system",
      actorName,
      action: e.action,
      summary: e.summary,
      targetType: e.targetType,
      targetId: e.targetId,
    });
  }
  await batch.commit();
}

export const auditEmployeeChanges = onDocumentWrittenWithAuthContext(
  "companies/{companyId}/employees/{employeeId}",
  async (event) => {
    const change = event.data;
    if (!change) return;
    try {
      const entries = describeEmployeeChange(
        change.before.data(),
        change.after.data(),
        event.params.employeeId,
      );
      await writeEntries(event.params.companyId, event.authType, event.authId, entries);
    } catch (error) {
      logger.error("監査ログ(メンバー)の記録に失敗しました", error);
    }
  },
);

export const auditCompanyChanges = onDocumentWrittenWithAuthContext("companies/{companyId}", async (event) => {
  const change = event.data;
  if (!change) return;
  try {
    const entries = describeCompanyChange(change.before.data(), change.after.data(), event.params.companyId);
    await writeEntries(event.params.companyId, event.authType, event.authId, entries);
  } catch (error) {
    logger.error("監査ログ(会社設定)の記録に失敗しました", error);
  }
});

export const auditTeamChanges = onDocumentWrittenWithAuthContext(
  "companies/{companyId}/teams/{teamId}",
  async (event) => {
    const change = event.data;
    if (!change) return;
    try {
      const entries = describeTeamChange(change.before.data(), change.after.data(), event.params.teamId);
      await writeEntries(event.params.companyId, event.authType, event.authId, entries);
    } catch (error) {
      logger.error("監査ログ(チーム)の記録に失敗しました", error);
    }
  },
);
