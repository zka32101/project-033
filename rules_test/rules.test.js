// Firestoreルールの動作テスト(エミュレータで実行)。
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const fs = require('fs');
const { doc, getDoc, setDoc, updateDoc, deleteDoc } = require('firebase/firestore');

let passed = 0, failed = 0;
async function check(name, fn) {
  try { await fn(); passed++; console.log('  PASS ' + name); }
  catch (e) { failed++; console.log('  FAIL ' + name + ' -> ' + (e.message || e).toString().split('\n')[0]); }
}

(async () => {
  const env = await initializeTestEnvironment({
    projectId: 'rules-test',
    firestore: { rules: fs.readFileSync(process.env.RULES_PATH || require('path').join(__dirname, '..', 'firestore.rules'), 'utf8'), host: '127.0.0.1', port: 8080 },
  });
  const C = 'co1';
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, `companies/${C}`), {
      name: 'T', planType: 'trial', contractedHeadcount: 5, trialEndsAt: new Date('2026-12-01'),
      moduleDeadlines: {}, createdAt: new Date('2026-01-01'),
    });
    await setDoc(doc(db, `companies/${C}/employees/admin1`), { companyId: C, role: 'admin', displayName: 'A' });
    await setDoc(doc(db, `companies/${C}/employees/admin2`), { companyId: C, role: 'admin', displayName: 'A2' });
    await setDoc(doc(db, `companies/${C}/employees/admin3`), { companyId: C, role: 'admin', displayName: 'A3' });
    await setDoc(doc(db, `companies/${C}/employees/mem1`), { companyId: C, role: 'member', displayName: 'M1' });
    await setDoc(doc(db, `companies/${C}/employees/mem3`), { companyId: C, role: 'member', displayName: 'M3' });
    await setDoc(doc(db, `companies/${C}/employees/mem4`), { companyId: C, role: 'member', displayName: 'M4' });
    await setDoc(doc(db, `companies/${C}/employees/old1`), { companyId: C, role: 'member', displayName: 'Old', deactivated: true });
    await setDoc(doc(db, `companies/${C}/auditLogs/l1`), { at: new Date(), actorId: 'admin1', summary: 'x', action: 'member.promoted' });
    await setDoc(doc(db, `companies/${C}/teams/t1`), { companyId: C, teamName: '営業' });
    await setDoc(doc(db, `companies/${C}/subscriptions/company_${C}`), { status: 'active' });
    await setDoc(doc(db, `companies/${C}/enrollments/e1`), { employeeId: 'mem1', moduleId: 'm1', status: 'completed' });
  });
  const as = (uid) => env.authenticatedContext(uid).firestore();
  const outsider = as('stranger');
  const admin = as('admin1');
  const member = as('mem1');
  const old = as('old1');

  console.log('--- 社員(employees) ---');
  await check('他人は社員ドキュメントを自分のuidで作れない(招待コード迂回の防止)', () =>
    assertFails(setDoc(doc(outsider, `companies/${C}/employees/stranger`), { companyId: C, role: 'member', displayName: 'X' })));
  await check('管理者でも社員を直接作れない', () =>
    assertFails(setDoc(doc(admin, `companies/${C}/employees/new1`), { companyId: C, role: 'member', displayName: 'X' })));
  await check('管理者は他の社員を管理者にできる', () =>
    assertSucceeds(updateDoc(doc(admin, `companies/${C}/employees/mem1`), { role: 'admin', lastEditedBy: 'admin1' })));
  await check('管理者は社員を無効化できる', () =>
    assertSucceeds(updateDoc(doc(admin, `companies/${C}/employees/admin2`), { deactivated: true, deactivatedAt: new Date(), lastEditedBy: 'admin1' })));
  await check('管理者でも無効化の解除はできない(席数確認のFunctionsだけ)', () =>
    assertFails(updateDoc(doc(admin, `companies/${C}/employees/old1`), { deactivated: false, lastEditedBy: 'admin1' })));
  await check('管理者でも社員の会社を付け替えられない', () =>
    assertFails(updateDoc(doc(admin, `companies/${C}/employees/mem1`), { companyId: 'other', lastEditedBy: 'admin1' })));
  await check('無効化された社員は会社の情報を読めない', () =>
    assertFails(getDoc(doc(old, `companies/${C}`))));
  await check('無効化された社員は自分の受講記録も読めない', () =>
    assertFails(getDoc(doc(old, `companies/${C}/enrollments/e1`))));
  await check('無効化された社員は自分の社員ドキュメントを更新できない(解除の自己操作も不可)', () =>
    assertFails(updateDoc(doc(old, `companies/${C}/employees/old1`), { deactivated: false })));
  await check('無効化された管理者は管理者として振る舞えない', async () => {
    // admin2は上のテストで無効化済み
    await assertFails(updateDoc(doc(as('admin2'), `companies/${C}/employees/mem1`), { displayName: 'hack' }));
  });
  await check('メンバーは自分を管理者にできない', () =>
    assertFails(updateDoc(doc(as('mem3'), `companies/${C}/employees/mem3`), { role: 'admin' })));
  await check('メンバーは自分の無効化フラグを操作できない', () =>
    assertFails(updateDoc(doc(as('mem4'), `companies/${C}/employees/mem4`), { deactivated: true })));
  await check('メンバーは自分の表示名を更新できる', async () => {
    // mem1は管理者に昇格済みなので、別のメンバーで確認する
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `companies/${C}/employees/mem2`), { companyId: C, role: 'member', displayName: 'M2' });
    });
    await assertSucceeds(updateDoc(doc(as('mem2'), `companies/${C}/employees/mem2`), { displayName: 'M2改', jobRole: 'sales' }));
  });
  await check('会社の外の人は社員一覧を読めない', () =>
    assertFails(getDoc(doc(outsider, `companies/${C}/employees/admin1`))));

  console.log('--- 会社(companies)・契約(subscriptions) ---');
  await check('会社は直接作成できない', () =>
    assertFails(setDoc(doc(outsider, 'companies/fake'), { name: 'X', planType: 'team', contractedHeadcount: 1000 })));
  await check('管理者はお試し期限を延ばせない', () =>
    assertFails(updateDoc(doc(admin, `companies/${C}`), { trialEndsAt: new Date('2099-01-01'), lastEditedBy: 'admin1' })));
  await check('管理者はplanTypeをteamに書き換えられない', () =>
    assertFails(updateDoc(doc(admin, `companies/${C}`), { planType: 'team', lastEditedBy: 'admin1' })));
  await check('管理者は人数上限を引き上げられない', () =>
    assertFails(updateDoc(doc(admin, `companies/${C}`), { contractedHeadcount: 1000, lastEditedBy: 'admin1' })));
  await check('管理者はbillingSourceを書き換えられない', () =>
    assertFails(updateDoc(doc(admin, `companies/${C}`), { billingSource: 'invoice', lastEditedBy: 'admin1' })));
  await check('管理者は会社情報・受講対象の指定を更新できる', () =>
    assertSucceeds(updateDoc(doc(admin, `companies/${C}`), {
      profile: { employeeCount: 30, traits: ['vehicles'] }, assignedModuleIds: ['m1'], lastEditedBy: 'admin1',
    })));
  await check('管理者は契約情報(subscriptions)を書き換えられない', () =>
    assertFails(setDoc(doc(admin, `companies/${C}/subscriptions/company_${C}`), { status: 'active', planTier: 'upper', fullSet: true })));
  await check('メンバーは契約情報を読める', () =>
    assertSucceeds(getDoc(doc(as('mem2'), `companies/${C}/subscriptions/company_${C}`))));

  console.log('--- チーム別の必須研修 ---');
  await check('管理者はチームの追加の必須研修を設定できる', () =>
    assertSucceeds(updateDoc(doc(as('admin1'), `companies/${C}/teams/t1`), { assignedModuleIds: ['m1', 'm2'], lastEditedBy: 'admin1' })));
  await check('メンバーはチームの追加の必須研修を読める(ホームの必須表示に使う)', () =>
    assertSucceeds(getDoc(doc(as('mem4'), `companies/${C}/teams/t1`))));
  await check('メンバーはチームの設定を書き換えられない', () =>
    assertFails(updateDoc(doc(as('mem4'), `companies/${C}/teams/t1`), { assignedModuleIds: [] })));
  await check('会社の外の人はチームの設定を読めない', () =>
    assertFails(getDoc(doc(outsider, `companies/${C}/teams/t1`))));
  await check('無効化された社員はチームの設定を読めない', () =>
    assertFails(getDoc(doc(old, `companies/${C}/teams/t1`))));

  console.log('--- 監査ログ(auditLogs) ---');
  await check('管理者は操作履歴を読める', () =>
    assertSucceeds(getDoc(doc(as('admin1'), `companies/${C}/auditLogs/l1`))));
  await check('メンバーは操作履歴を読めない', () =>
    assertFails(getDoc(doc(as('mem4'), `companies/${C}/auditLogs/l1`))));
  await check('管理者でも操作履歴を書き換えられない(改ざん防止)', () =>
    assertFails(updateDoc(doc(as('admin1'), `companies/${C}/auditLogs/l1`), { summary: '改ざん' })));
  await check('管理者でも操作履歴を削除できない', () =>
    assertFails(deleteDoc(doc(as('admin1'), `companies/${C}/auditLogs/l1`))));
  await check('管理者でも操作履歴を新しく作れない(偽造防止)', () =>
    assertFails(setDoc(doc(as('admin1'), `companies/${C}/auditLogs/fake`), { summary: '偽の履歴' })));
  await check('無効化された社員は操作履歴を読めない', () =>
    assertFails(getDoc(doc(old, `companies/${C}/auditLogs/l1`))));

  console.log('--- 実行者スタンプ(lastEditedBy) ---');
  // 注: ドキュメントには前回のスタンプが残る。同じ管理者がスタンプなしで書いても、結果のスタンプは本人のuidのままで、
  // 監査ログの操作者は正しく本人になる。別の管理者(残っているスタンプが他人)は、必ず自分のスタンプが必要。
  await check('別の管理者がスタンプなしで書くと拒否される(操作者が他人のまま記録されるため)', () =>
    assertFails(updateDoc(doc(as('admin3'), `companies/${C}`), { assignedModuleIds: ['m1'] })));
  await check('他人のuidを書いた偽装スタンプは拒否される', () =>
    assertFails(updateDoc(doc(as('admin3'), `companies/${C}`), { assignedModuleIds: ['m1'], lastEditedBy: 'admin1' })));
  await check('自分のuidのスタンプがあれば許可される', () =>
    assertSucceeds(updateDoc(doc(as('admin3'), `companies/${C}`), { assignedModuleIds: ['m1'], lastEditedBy: 'admin3' })));
  await check('社員の役割変更も、スタンプがなければ拒否される', () =>
    assertFails(updateDoc(doc(as('admin1'), `companies/${C}/employees/mem3`), { role: 'admin' })));
  await check('社員の役割変更で他人のuidを書いた偽装は拒否される', () =>
    assertFails(updateDoc(doc(as('admin1'), `companies/${C}/employees/mem3`), { role: 'admin', lastEditedBy: 'mem4' })));
  await check('チームの設定もスタンプが必要(なし・偽装は拒否、本人のuidは許可)', async () => {
    await assertFails(updateDoc(doc(as('admin3'), `companies/${C}/teams/t1`), { assignedModuleIds: ['m1'] }));
    await assertFails(updateDoc(doc(as('admin3'), `companies/${C}/teams/t1`), { assignedModuleIds: ['m1'], lastEditedBy: 'x' }));
    await assertSucceeds(updateDoc(doc(as('admin3'), `companies/${C}/teams/t1`), { assignedModuleIds: ['m1'], lastEditedBy: 'admin3' }));
  });
  await check('チームの作成にもスタンプが必要', async () => {
    await assertFails(setDoc(doc(as('admin1'), `companies/${C}/teams/t9`), { companyId: C, teamName: '新' }));
    await assertSucceeds(setDoc(doc(as('admin1'), `companies/${C}/teams/t9`), { companyId: C, teamName: '新', lastEditedBy: 'admin1' }));
  });
  await check('メンバーの自分の更新(表示名・職種)にはスタンプは不要', () =>
    assertSucceeds(updateDoc(doc(as('mem4'), `companies/${C}/employees/mem4`), { jobRole: 'sales' })));

  console.log('--- 職種別の必須研修 ---');
  await check('管理者は職種別の必須研修を設定できる(スタンプ付き)', () =>
    assertSucceeds(updateDoc(doc(as('admin3'), `companies/${C}`), { roleAssignments: { sales: ['m1'] }, lastEditedBy: 'admin3' })));
  await check('メンバーは職種別の必須研修を設定できない', () =>
    assertFails(updateDoc(doc(as('mem4'), `companies/${C}`), { roleAssignments: { sales: [] }, lastEditedBy: 'mem4' })));
  await check('管理者は他のメンバーの職種を設定できる(スタンプ付き)', () =>
    assertSucceeds(updateDoc(doc(as('admin3'), `companies/${C}/employees/mem3`), { jobRole: 'accounting', lastEditedBy: 'admin3' })));
  await check('メンバーは自分の職種を変更できる(従来どおり)', () =>
    assertSucceeds(updateDoc(doc(as('mem4'), `companies/${C}/employees/mem4`), { jobRole: 'it' })));

  await env.cleanup();
  console.log(`\n結果: ${passed} PASS / ${failed} FAIL`);
  process.exit(failed ? 1 : 0);
})();
