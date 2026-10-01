# Firestoreルールのテスト

`../firestore.rules` を、Firestoreエミュレータで実際に評価して検証する(決済の迂回・招待コードの迂回・
無効化された社員のアクセスなど、セキュリティ上重要な振る舞い)。

```bash
cd rules_test
npm ci
npm test
```

- JDK 11以上が必要(firebase-tools 13系)。CIでは `.github/workflows/test.yml` の `rules` ジョブで実行する。
- ルールを変更したら、対応するテストを `rules.test.js` に追加すること。
