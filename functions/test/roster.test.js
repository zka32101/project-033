const test = require("node:test");
const assert = require("node:assert");
const { validateRoster, generateCode } = require("../lib/roster");

const teams = new Map([
  ["営業部", "t1"],
  ["総務部", "t2"],
]);

test("正しい名簿は、チームIDと職種つきで受け付ける", () => {
  const r = validateRoster(
    [
      { name: " 佐藤 ", teamName: "営業部", jobRole: "sales" },
      { name: "鈴木", teamName: "総務部" },
    ],
    teams,
    5,
  );
  assert.deepStrictEqual(r.errors, []);
  assert.deepStrictEqual(r.rows[0], { name: "佐藤", teamId: "t1", teamName: "営業部", jobRole: "sales" });
  assert.strictEqual(r.rows[1].jobRole, null);
});

test("名前なし・未知のチーム・不正な職種・重複は行番号つきで報告", () => {
  const r = validateRoster(
    [
      { name: "", teamName: "営業部" },
      { name: "田中", teamName: "存在しない" },
      { name: "高橋", teamName: "営業部", jobRole: "ceo" },
      { name: "伊藤", teamName: "営業部" },
      { name: "伊藤", teamName: "営業部" },
    ],
    teams,
    10,
  );
  assert.strictEqual(r.errors.length, 4);
  assert.match(r.errors[0], /^1行目/);
  assert.match(r.errors[1], /^2行目.*存在しない/);
  assert.match(r.errors[2], /^3行目.*ceo/);
  assert.match(r.errors[3], /^5行目.*重複/);
});

test("同名でもチームが違えば重複ではない", () => {
  const r = validateRoster(
    [
      { name: "山田", teamName: "営業部" },
      { name: "山田", teamName: "総務部" },
    ],
    teams,
    2,
  );
  assert.deepStrictEqual(r.errors, []);
});

test("空き席が足りなければ登録しない", () => {
  const r = validateRoster(
    [
      { name: "A", teamName: "営業部" },
      { name: "B", teamName: "営業部" },
    ],
    teams,
    1,
  );
  assert.match(r.errors[0], /空き席が足りません\(空き1席・取り込み2人\)/);
});

test("空・上限超過は拒否", () => {
  assert.ok(validateRoster([], teams, 5).errors.length > 0);
  const many = Array.from({ length: 201 }, (_, i) => ({ name: `n${i}`, teamName: "営業部" }));
  assert.match(validateRoster(many, teams, 999).errors[0], /200人まで/);
});

test("コードは8文字で、紛らわしい文字を含まない", () => {
  for (let i = 0; i < 200; i++) {
    assert.match(generateCode(), /^[A-HJ-NP-Z2-9]{8}$/);
  }
});
