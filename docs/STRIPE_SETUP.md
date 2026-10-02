# Stripe 本番化の手順(法人の請求書払い)

テストモードで作成済み: 商品 `prod_VMH89EPxFjdZCa` / Price `price_1ULYaFL7OVHZPnNe2U4cK50M`(1人月300円・税別)。
キーは `H:\マイドライブ\key\safy\stripe\stripe-test-keys.txt`(リポジトリ外)。
Functions は `functions/src/stripe.ts`(`createCheckoutSession` / `createBillingPortalSession` / `stripeWebhook`)。**未デプロイ**。

以下は、接続するときの順番。

## 1. Secret と環境変数の登録(PowerShell、プロジェクト safy-15db7)

値はコマンドを実行すると入力を求められる。画面やチャットに貼らない。

```powershell
firebase functions:secrets:set STRIPE_SECRET_KEY --project safy-15db7
firebase functions:secrets:set STRIPE_PRICE_ID --project safy-15db7
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET --project safy-15db7
```

- `STRIPE_SECRET_KEY`: テストは `sk_test_...`(本番は `sk_live_...`)
- `STRIPE_PRICE_ID`: `price_1ULYaFL7OVHZPnNe2U4cK50M`(本番用に作り直した場合はそのID)
- `STRIPE_WEBHOOK_SECRET`: 手順3の後に本物を入れる。先に仮の値(`whsec_pending`)で登録して、デプロイを通す。

`functions/.env`(コミットしない)に、決済後の戻り先を書く。

```
BILLING_RETURN_URL=https://(戻り先のURL)
```

## 2. デプロイ

```powershell
firebase deploy --only functions:createCheckoutSession,functions:createBillingPortalSession,functions:stripeWebhook --project safy-15db7
```

デプロイ後、Webhook の URL は次になる(region us-central1)。
`https://us-central1-safy-15db7.cloudfunctions.net/stripeWebhook`
新しい関数は、直後に 401 が出ることがある(IAMの反映待ち)。90秒ほど待つ。

## 3. Stripe に Webhook を登録

ダッシュボード → 開発者 → Webhook → エンドポイントを追加。

- URL: 上のURL
- イベント: `checkout.session.completed` / `customer.subscription.created` / `customer.subscription.updated` / `customer.subscription.deleted`
- 作成後に表示される「署名シークレット」(`whsec_...`)を、手順1の `STRIPE_WEBHOOK_SECRET` に設定し直し、`stripeWebhook` だけ再デプロイする。

## 4. Stripe Tax・請求書(ユーザー作業)

- 事業者情報の入力、Stripe Tax の有効化(税別表示)、銀行振込の設定。
- 適格請求書発行事業者の登録番号は未取得のため、契約案内は「適格請求書(インボイス)には現在対応していません」と表示している。取得後に案内文を更新する。

## 5. 結合確認(テストモード)

1. 管理者で「ご契約について」→ 内容を確認 → Checkout へ
2. テストカード `4242 4242 4242 4242` で決済
3. Webhook で `companies/{id}/subscriptions/company_{id}` が更新され、人数上限が契約人数になる
4. Billing Portal から解約 → お試し終了と同じ状態(契約案内画面)に戻り、利用が止まる

## 6. 本番へ切り替え

テストの商品・Price・キー・Webhook を、本番モードで作り直し、Secret を入れ替えて再デプロイする。
