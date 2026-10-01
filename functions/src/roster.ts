/**
 * 社員の一括登録(名簿)。
 *
 * 管理者がCSVで取り込んだ名簿(名前・チーム・職種)から、1人ごとの使い切りの招待コードを発行する。
 * 社員がそのコードで参加すると、名簿どおりの名前・チーム・職種で登録される(joinCompanyViaInvite)。
 * 名簿は companies/{id}/roster/{コード} に保存し、読み取りは管理者のみ・書き込みはこの関数だけ。
 */

import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";

export const MAX_ROSTER_ENTRIES = 200;
export const JOB_ROLE_IDS = ["newcomer", "accounting", "hr_ga", "sales", "purchasing", "it", "manager"];

export interface RosterInput {
  name?: unknown;
  teamName?: unknown;
  jobRole?: unknown;
}

export interface RosterRow {
  name: string;
  teamId: string;
  teamName: string;
  jobRole: string | null;
}

export interface RosterValidation {
  rows: RosterRow[];
  /** 1始まりの行番号つきのエラー。1件でもあれば登録しない。 */
  errors: string[];
}

/** 入力の検証。teams は チーム名→チームID。 */
export function validateRoster(
  inputs: RosterInput[],
  teams: Map<string, string>,
  freeSeats: number,
): RosterValidation {
  const errors: string[] = [];
  const rows: RosterRow[] = [];
  if (inputs.length === 0) errors.push("取り込む行がありません");
  if (inputs.length > MAX_ROSTER_ENTRIES) {
    errors.push(`一度に取り込めるのは${MAX_ROSTER_ENTRIES}人までです`);
  }
  const seen = new Set<string>();
  inputs.slice(0, MAX_ROSTER_ENTRIES).forEach((input, i) => {
    const line = i + 1;
    const name = typeof input.name === "string" ? input.name.trim() : "";
    const teamName = typeof input.teamName === "string" ? input.teamName.trim() : "";
    const role = typeof input.jobRole === "string" ? input.jobRole.trim() : "";
    if (!name) {
      errors.push(`${line}行目: 名前がありません`);
      return;
    }
    if (name.length > 50) {
      errors.push(`${line}行目: 名前が長すぎます`);
      return;
    }
    const key = `${teamName}\u0000${name}`;
    if (seen.has(key)) {
      errors.push(`${line}行目: 「${name}」さんが同じチームで重複しています`);
      return;
    }
    seen.add(key);
    const teamId = teams.get(teamName);
    if (!teamName || teamId === undefined) {
      errors.push(`${line}行目: チーム「${teamName}」が見つかりません`);
      return;
    }
    if (role && !JOB_ROLE_IDS.includes(role)) {
      errors.push(`${line}行目: 職種「${role}」が正しくありません`);
      return;
    }
    rows.push({ name, teamId, teamName, jobRole: role || null });
  });
  if (errors.length === 0 && rows.length > freeSeats) {
    errors.push(`空き席が足りません(空き${Math.max(freeSeats, 0)}席・取り込み${rows.length}人)`);
  }
  return { rows, errors };
}

const CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

export function generateCode(random: (n: number) => number = (n) => Math.floor(Math.random() * n)): string {
  let s = "";
  for (let i = 0; i < 8; i++) s += CODE_CHARS[random(CODE_CHARS.length)];
  return s;
}

async function requireAdmin(
  db: FirebaseFirestore.Firestore,
  uid: string | undefined,
  companyId: string | undefined,
) {
  if (!uid) throw new HttpsError("unauthenticated", "サインインが必要です");
  if (!companyId) throw new HttpsError("invalid-argument", "入力内容を確認してください");
  const companyRef = db.collection("companies").doc(companyId);
  const caller = (await companyRef.collection("employees").doc(uid).get()).data();
  if (caller?.role !== "admin" || caller?.deactivated === true) {
    throw new HttpsError("permission-denied", "この会社の管理者のみ実行できます");
  }
  const company = (await companyRef.get()).data();
  if (!company) throw new HttpsError("not-found", "会社情報が見つかりませんでした");
  return { companyRef, company, callerName: (caller?.displayName as string | undefined) ?? "管理者" };
}

/** 名簿のうち、まだ参加していない(席を確保している)人数。 */
export async function countPendingRoster(companyRef: FirebaseFirestore.DocumentReference): Promise<number> {
  const snap = await companyRef.collection("roster").where("status", "==", "pending").count().get();
  return snap.data().count;
}

export const createRoster = onCall({ region: "us-central1" }, async (request) => {
  const db = admin.firestore();
  const { companyId, entries } = request.data as { companyId?: string; entries?: RosterInput[] };
  const { companyRef, company, callerName } = await requireAdmin(db, request.auth?.uid, companyId);
  if (!Array.isArray(entries)) throw new HttpsError("invalid-argument", "入力内容を確認してください");
  if (company.trialEndsAt && company.trialEndsAt.toMillis() < Date.now()) {
    throw new HttpsError("failed-precondition", "お試し期間が終了しています");
  }

  const teamSnap = await companyRef.collection("teams").get();
  const teams = new Map<string, string>();
  teamSnap.docs.forEach((d) => teams.set(String(d.data().teamName ?? ""), d.id));

  const employees = companyRef.collection("employees");
  const [total, deactivated, pending] = await Promise.all([
    employees.count().get(),
    employees.where("deactivated", "==", true).count().get(),
    countPendingRoster(companyRef),
  ]);
  const used = total.data().count - deactivated.data().count + pending;
  const freeSeats = (company.contractedHeadcount ?? 1) - used;

  const { rows, errors } = validateRoster(entries, teams, freeSeats);
  if (errors.length > 0) {
    throw new HttpsError("invalid-argument", errors.slice(0, 10).join("\n"));
  }

  const batch = db.batch();
  const now = admin.firestore.Timestamp.now();
  const result: { code: string; name: string; teamName: string; jobRole: string | null }[] = [];
  const issued = new Set<string>();
  for (const row of rows) {
    let code = generateCode();
    while (issued.has(code) || (await db.collection("inviteCodes").doc(code).get()).exists) {
      code = generateCode();
    }
    issued.add(code);
    batch.set(db.collection("inviteCodes").doc(code), {
      companyId,
      teamId: row.teamId,
      personal: true,
      isActive: true,
      createdAt: now,
    });
    batch.set(companyRef.collection("roster").doc(code), {
      name: row.name,
      teamId: row.teamId,
      teamName: row.teamName,
      jobRole: row.jobRole,
      status: "pending",
      createdAt: now,
    });
    result.push({ code, name: row.name, teamName: row.teamName, jobRole: row.jobRole });
  }
  batch.set(companyRef.collection("auditLogs").doc(), {
    at: now,
    actorId: request.auth!.uid,
    actorName: callerName,
    action: "roster.created",
    summary: `社員の名簿を一括登録しました(${rows.length}人)`,
    targetType: "company",
    targetId: companyId,
  });
  await batch.commit();
  return { entries: result };
});

export const revokeRosterEntry = onCall({ region: "us-central1" }, async (request) => {
  const db = admin.firestore();
  const { companyId, code } = request.data as { companyId?: string; code?: string };
  const { companyRef, callerName } = await requireAdmin(db, request.auth?.uid, companyId);
  if (!code) throw new HttpsError("invalid-argument", "入力内容を確認してください");
  const ref = companyRef.collection("roster").doc(code.toUpperCase());
  const entry = (await ref.get()).data();
  if (!entry) throw new HttpsError("not-found", "名簿に見つかりません");
  if (entry.status !== "pending") {
    throw new HttpsError("failed-precondition", "参加済み、または取消済みのため取り消せません");
  }
  const batch = db.batch();
  batch.update(ref, { status: "revoked" });
  batch.update(db.collection("inviteCodes").doc(code.toUpperCase()), { isActive: false });
  batch.set(companyRef.collection("auditLogs").doc(), {
    at: admin.firestore.Timestamp.now(),
    actorId: request.auth!.uid,
    actorName: callerName,
    action: "roster.revoked",
    summary: `名簿の「${String(entry.name)}」さんの招待コードを取り消しました`,
    targetType: "company",
    targetId: companyId,
  });
  await batch.commit();
  return { revoked: true };
});
