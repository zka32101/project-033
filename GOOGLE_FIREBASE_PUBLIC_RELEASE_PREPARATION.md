# Google・Firebase 公開リリース準備ガイド
## Google & Firebase Public Release Preparation Guide

**作成日** / Created: Sep 4, 2026  
**対象期間** / Period: Sep 9-Nov 26, 2026 (公開前準備期間)  
**目標** / Objective: Dec 1本番ローンチに向けたGoogle・Firebase全体セットアップ 100%完了  
**主要マイルストーン** / Key Milestones:
- Sep 15: GATE 2 - Firebase本番環境検証完了
- Nov 1: ソフトローンチ - Google Play Beta版配布開始
- Nov 26: GATE 5 - 本番ローンチ準備完了
- Dec 1: 本番ローンチ - Google Play正式リリース

---

## 1. Firebase プロジェクトセットアップ
### Firebase Project Configuration

### 1.1 プロジェクト構成 (Project Structure)

```
Safy Firebase プロジェクト体系:
├─ Development環境 (開発・テスト)
│  ├─ safy-dev-japan (日本開発環境)
│  ├─ safy-dev-staging (ステージング環境)
│  └─ safy-dev-testing (テスト環境)
│
├─ Production環境 (本番)
│  ├─ safy-production-primary (プライマリ本番)
│  ├─ safy-production-asia (アジア本番)
│  └─ safy-production-dr (ディザスタリカバリ)
│
└─ Analytics環境 (分析)
   └─ safy-analytics (統合ダッシュボード)
```

### 1.2 各プロジェクト詳細設定

#### Development環境: safy-dev-japan

**用途:** ローカル開発・ユニットテスト・統合テスト

**Firebaseサービス有効化:**
```
✓ Firebase Authentication (メール・Google・Apple)
✓ Cloud Firestore (データベース)
✓ Cloud Storage (ファイル保存)
✓ Firebase Functions (バックエンド)
✓ Firebase Realtime Database (リアルタイム通知)
✓ Cloud Messaging (プッシュ通知)
✓ Firebase Analytics (イベント追跡)
✓ Firebase Crashlytics (エラー報告)
✓ Remote Config (リモート設定)
✓ A/B Testing (実験フレームワーク)
✓ Performance Monitoring (パフォーマンス監視)
```

**セットアップ手順:**
```
Step 1: Firebase Console プロジェクト作成
  └─ Project ID: safy-dev-japan
  └─ Region: asia-northeast1 (東京)
  └─ Organization: Safy Inc.

Step 2: Google Cloud Platform (GCP) リンク
  └─ Billing Account: 開発チーム用
  └─ API: Cloud Firestore API, Cloud Functions API, etc.

Step 3: Authentication セットアップ
  └─ Email/Password 認証有効化
  └─ Google OAuth 設定 (開発アプリID)
  └─ Apple Sign-In 設定 (開発チームID)
  └─ User Verification: メール確認必須

Step 4: Firestore Database セットアップ
  └─ Mode: Test mode (開発用セキュリティルール)
  └─ Region: asia-northeast1
  └─ Create Collections:
     ├─ users (ユーザー情報)
     ├─ contents (コンテンツ)
     ├─ courses (コース管理)
     ├─ enrollments (受講情報)
     ├─ progress (進捗情報)
     ├─ payments (支払い情報)
     └─ notifications (通知ログ)

Step 5: Cloud Storage セットアップ
  └─ Bucket: safy-dev-japan-storage
  └─ Region: asia-northeast1
  └─ Folders:
     ├─ /user-avatars (ユーザー画像)
     ├─ /content-assets (コンテンツ素材)
     ├─ /certificates (修了証)
     └─ /documents (ドキュメント)

Step 6: Firebase Functions デプロイ
  └─ Runtime: Node.js 20.x
  └─ Functions:
     ├─ createUser (ユーザー作成時トリガー)
     ├─ sendVerificationEmail (メール検証)
     ├─ recordContentView (コンテンツ閲覧ログ)
     ├─ updateProgress (進捗更新)
     ├─ processPayment (支払い処理)
     └─ sendNotification (通知送信)

Step 7: Cloud Messaging (FCM) セットアップ
  └─ Server Key: 取得
  └─ Sender ID: 取得
  └─ Topics: 作成
     ├─ announcements (通知)
     ├─ course-updates (コース更新)
     └─ promotions (プロモーション)

Step 8: Analytics セットアップ
  └─ Enable: Google Analytics for Firebase
  └─ Custom Events: 定義
     ├─ content_started
     ├─ content_completed
     ├─ payment_completed
     ├─ user_signup
     └─ user_login
```

**Deadline:** Sep 9

#### Staging環境: safy-dev-staging

**用途:** ステージング環境テスト・本番環境シミュレーション

**設定:**
```
Development環境と同一構成ですが、本番に近いセキュリティルール実装
└─ Firestore Rules: 本番版テスト
└─ Authentication: 本番版設定テスト
└─ Functions: 本番コード検証
└─ Storage: CORS設定テスト
```

**Deadline:** Sep 11

#### Production環境: safy-production-primary

**用途:** 本番環境 (Dec 1ローンチ)

**セットアップ手順:**

```
Step 1: プロジェクト作成
  └─ Project ID: safy-production-primary
  └─ Region: asia-northeast1 (プライマリ)
  └─ Organization: Safy Inc.
  └─ Billing: Production Account (有料)

Step 2: GCP リンク & 課金設定
  └─ Billing Account: Production
  └─ Budget Alert: $10,000/月で警告

Step 3: Identity & Access Management (IAM)
  └─ Roles 設定:
     ├─ Firebase Admin: Tech Lead + DevOps
     ├─ Firebase Developer: 全開発チーム
     ├─ Firebase Viewer: 全チーム (読み取り)
     └─ Service Accounts: API統合用

Step 4: Authentication (本番版)
  └─ Email/Password: Production設定
  └─ Google OAuth: 正式アプリID設定
  └─ Apple Sign-In: 正式チームID設定
  └─ ReCaptcha v3: Bot対策
  └─ Email Template: カスタマイズ
     ├─ ユーザー確認メール
     ├─ パスワードリセット
     ├─ メール確認リンク
     └─ ウェルカムメール

Step 5: Firestore Database (本番版)
  └─ Mode: Production mode (セキュリティルール必須)
  └─ Regional Database: asia-northeast1
  └─ Backup: 日次自動バックアップ有効化
  └─ Collections:
     ├─ users (リード: 100K/日, ライト: 50K/日想定)
     ├─ contents (リード: 500K/日)
     ├─ courses
     ├─ enrollments
     ├─ progress
     ├─ payments
     ├─ notifications
     ├─ audit_logs (監査ログ)
     └─ system_config (システム設定)

Step 6: Firestore Security Rules (本番版)
  └─ ルール実装内容:
     ├─ 認証ユーザーのみアクセス可
     ├─ ユーザーは自身のデータのみ読み取り可
     ├─ 管理者は全データ読み取り可
     ├─ コンテンツは全ユーザーが読み取り可
     ├─ 支払い情報は暗号化・管理者のみ
     └─ 監査ログは追記のみ・削除不可

Step 7: Cloud Storage (本番版)
  └─ Bucket: safy-production-primary-storage
  └─ Region: asia-northeast1
  └─ CORS設定: 本番ドメイン許可
  └─ CDN Integration: Google Cloud CDN有効化
  └─ Signed URLs: 有効期限付きURL発行
  └─ Lifecycle Policy: 不要ファイル自動削除
     ├─ Temp files: 24時間で削除
     ├─ Backups: 30日で削除
     └─ Logs: 90日で削除

Step 8: Firebase Functions (本番版)
  └─ Runtime: Node.js 20.x (最新)
  └─ Memory: 2GB
  └─ Timeout: 540秒
  └─ VPC: GCP VPC 接続
  └─ Functions:
     ├─ createUser (非同期)
     ├─ sendVerificationEmail (非同期)
     ├─ recordContentView (バッチ処理)
     ├─ updateProgress (リアルタイム)
     ├─ processPayment (同期・重要)
     ├─ generateCertificate (非同期)
     ├─ sendNotification (非同期バッチ)
     └─ scheduleMaintenanceWindow (定期)

Step 9: Realtime Database (本番版)
  └─ Node: /notifications (リアルタイム通知)
  └─ Node: /presence (ユーザーオンライン状態)
  └─ Node: /messaging (チャット・メッセージング)
  └─ Retention: 最新1000レコードのみ保持

Step 10: Cloud Messaging (FCM) (本番版)
  └─ Server Key: 本番環境キー
  └─ Sender ID: 本番環境ID
  └─ Topics:
     ├─ announcements (全員購読)
     ├─ course-updates (コース購読者)
     ├─ promotions (ユーザー設定可)
     └─ system-alerts (緊急通知)
  └─ Message Template: 多言語対応
  └─ APNs Certificate: iOS本番証明書設定
  └─ FCM Android: Android本番設定

Step 11: Analytics (本番版)
  └─ Google Analytics 4 リンク
  └─ Event Tracking:
     ├─ user signup (新規登録)
     ├─ user login (ログイン)
     ├─ content_viewed (コンテンツ閲覧)
     ├─ lesson_started (レッスン開始)
     ├─ lesson_completed (レッスン完了)
     ├─ payment_initiated (支払い開始)
     ├─ payment_completed (支払い完了)
     ├─ user_deleted (アカウント削除)
     └─ error_occurred (エラー発生)
  └─ User Properties:
     ├─ user_tier (ユーザーレベル)
     ├─ days_active (活動日数)
     ├─ lifetime_value (LTV)
     └─ language (言語設定)
  └─ Conversion Goals:
     ├─ payment (支払い完了)
     ├─ lesson_completion (レッスン完了)
     └─ 7day_retention (7日以上継続)

Step 12: Crashlytics & Performance (本番版)
  └─ Crashlytics: エラー自動報告
  └─ Performance Monitoring: 
     ├─ App Startup Time
     ├─ Screen Rendering
     ├─ HTTP Network Request
     └─ Custom Traces

Step 13: Remote Config (本番版)
  └─ Parameters:
     ├─ min_app_version (最小アプリバージョン)
     ├─ max_users_per_course (コース最大定員)
     ├─ payment_gateway_enabled (支払い有効化)
     ├─ feature_flags (機能フラグ)
     └─ ui_theme_config (UIテーマ設定)

Step 14: A/B Testing (本番版)
  └─ Experiments:
     ├─ pricing_experiment (価格テスト)
     ├─ ui_variant_test (UI変更テスト)
     └─ onboarding_flow_test (オンボーディングテスト)

Step 15: Backup & Disaster Recovery
  └─ Firestore Backup: 日次 (Asia region)
  └─ Storage Backup: 日次 (複数リージョン)
  └─ RTO: 4時間
  └─ RPO: 24時間
```

**Deadline:** Oct 7

#### Production環境: safy-production-asia

**用途:** アジア地域専用ミラー (SE Asia, Korea)

**設定:**
```
safy-production-primary と同期構成
└─ Region: asia-southeast1 (シンガポール)
└─ Database Replication: Asia region specific
└─ Backup: asia-southeast1にも保存
```

**Deadline:** Oct 14

#### Production環境: safy-production-dr

**用途:** ディザスタリカバリ (全国復旧用)

**設定:**
```
Backup専用 + 復旧テスト環境
└─ Region: us-central1 (地理的に遠い)
└─ Backup: safy-production-primary の定期復旧テスト
└─ RTO Test: 毎月1回実施
```

**Deadline:** Oct 21

---

## 2. Google Play Store セットアップ
### Google Play Store Release Preparation

### 2.1 Google Play Console アカウント設定

**アカウント作成・検証:**
```
Step 1: Google Play Developer Account
  └─ Email: developer@safy.jp (専用メール)
  └─ Payment Method: 法人クレジットカード
  └─ Verification: 身分証明書・住所確認
  └─ 登録料金: $25 (一度のみ)

Step 2: Developer Account Details
  └─ Store Listing:
     ├─ App Developer Name: Safy Inc.
     ├─ Website: www.safy.jp
     ├─ Email: support@safy.jp
     ├─ Privacy Policy: https://www.safy.jp/privacy
     └─ Contact Information: 日本の住所

Step 3: Payment Settings
  └─ Merchant Account: 日本の銀行口座
  └─ Tax Information: 日本 (10%消費税適用)
  └─ Payout Threshold: $100 (自動振込)

Step 4: API & SDK Setup
  └─ Google Play Android Developer API: 有効化
  └─ Service Account: API統合用アカウント作成
  └─ JSON Key: ダウンロード・セキュア保存
```

**Deadline:** Sep 9

### 2.2 アプリケーション登録

**基本情報:**
```
Step 1: アプリ名・パッケージ登録
  └─ App Name: Safy
  └─ Package Name: jp.safy.android (一度のみ変更不可)
  └─ App Type: Education
  └─ Category: Education

Step 2: App Store Listing (日本語)
  └─ Title (短い): Safy - スキル習得プラットフォーム
  └─ Subtitle: 実践的なスキルを学ぶ
  └─ Short Description (80文字):
     "Safyで世界的に求められるスキルを習得。実務レベルのトレーニングで
     確実なキャリア成長を実現します。"
  
  └─ Full Description (4000文字):
     "Safyは、世界で求められるスキルを習得できるオンライン学習プラットフォーム。
     
     【主な特徴】
     ✓ 実践的なカリキュラム: プロの講師による本物のスキル習得
     ✓ インタラクティブレッスン: 動画・クイズ・プロジェクト実装
     ✓ コミュニティ: 同じ目標を持つ学習者との交流
     ✓ 修了証: キャリアに活かせる公式認定証
     ✓ キャリアサポート: 就職・転職のサポート
     
     【対象分野】
     • Web開発 (フロントエンド・バックエンド)
     • データサイエンス
     • クラウド技術 (AWS・GCP)
     • 営業スキル
     • マネジメント
     
     【学習体験】
     1. コース選択: 100+ の実践的なコースから選択
     2. レッスン実施: ビデオレッスン・ハンズオン練習
     3. プロジェクト実装: 実世界のシナリオで実装
     4. コミュニティ質問: 講師・メンターに質問可
     5. 修了・認定: 修了証を獲得・共有
     
     料金: 月額980円 (初月無料)
     無料体験: 7日間全てのコース利用可
     
     質問: support@safy.jp
     プライバシー: https://www.safy.jp/privacy"

Step 3: Screenshots & Media
  └─ Screenshots (最小5枚, 最大8枚):
     ├─ スクリーン1: ホーム画面 (コース一覧)
     ├─ スクリーン2: レッスン実施画面
     ├─ スクリーン3: プロジェクト実装
     ├─ スクリーン4: コミュニティ・質問機能
     ├─ スクリーン5: 修了証
     ├─ スクリーン6: ユーザープロフィール
     ├─ スクリーン7: 支払い画面
     └─ スクリーン8: 設定画面
  
  └─ スクリーンショット要件:
     ├─ 解像度: 1080x1920px (9:16 aspect ratio)
     ├─ フォーマット: PNG (最大2MB)
     ├─ テキスト: 日本語・読みやすいフォント
     ├─ キャプション: 各スクリーンに説明文 (90文字以下)
     └─ Safe Zone: 画面の端から24px以内にテキスト配置

  └─ フィーチャーグラフィック (Feature Image):
     ├─ 解像度: 1024x500px
     ├─ フォーマット: PNG/JPG
     ├─ 内容: アプリの価値提案を一目で伝える
     ├─ テキスト: 日本語で主要メッセージ
     └─ ファイルサイズ: 最大1MB

  └─ プレビュー動画 (Feature Video):
     ├─ 長さ: 15-30秒
     ├─ フォーマット: MP4 (H.264)
     ├─ 解像度: 1080p以上
     ├─ 音声: 日本語ナレーション + BGM
     ├─ 字幕: 日本語・英語対応
     ├─ 内容: アプリの使用方法・価値を伝える
     └─ ファイルサイズ: 最大500MB

  └─ Icon (アプリアイコン):
     ├─ 解像度: 512x512px (1:1)
     ├─ フォーマット: PNG (透明背景可)
     ├─ 内容: Safy ロゴ・シンプルで認識しやすい
     ├─ コーナー: 丸角推奨
     └─ ファイルサイズ: 最大1MB
```

**Deadline:** Oct 1

### 2.3 リリース設定

**ビルド・APK署名:**
```
Step 1: Android App Bundle (AAB) 準備
  └─ Build Tool: Gradle 8.0+
  └─ Compilation Target: Android 14 (API 34)
  └─ Minimum SDK: Android 8 (API 26)
  └─ Target SDK: Android 14 (API 34)

Step 2: Signing Configuration
  └─ Keystore 生成:
     ├─ Algorithm: RSA
     ├─ Key Size: 2048-bit
     ├─ Validity: 25年以上
     ├─ CN: Safy Inc.
     ├─ O: Safy Inc.
     └─ C: JP
  
  └─ APK 署名:
     ├─ Build: release build
     ├─ Signing Config: production keystore
     ├─ Optimization: Minify enabled (R8)
     └─ Verification: Verify signed APK

Step 3: AAB 生成
  └─ Command: ./gradlew bundleRelease
  └─ Output: app-release.aab
  └─ Size: < 100MB (推奨)

Step 4: Upload to Google Play Console
  └─ Step 1: AAB File Upload
  └─ Step 2: Review Pre-launch Report
  └─ Step 3: App Review & Compliance
```

**Deadline:** Nov 1 (Beta版), Nov 26 (正式版)

### 2.4 コンプライアンス & 審査

**プライバシー & セキュリティ:**
```
Step 1: Privacy Policy
  └─ URL: https://www.safy.jp/privacy (日本語)
  └─ 内容:
     ├─ 個人情報の収集・使用
     ├─ Cookie・トラッキング
     ├─ データの第三者共有
     ├─ ユーザー権利・削除方法
     └─ 変更履歴

Step 2: データ安全
  └─ Data Safety Form (Google Play Console):
     ├─ 個人情報のタイプ: Email, Name, Phone, Location
     ├─ データ暗号化: すべてのデータはHTTPS暗号化
     ├─ ユーザーが削除可能: はい
     ├─ 第三者共有: Google Analytics, Firebase
     ├─ セキュリティ慣行: セキュリティテスト実施
     └─ エンドツーエンド暗号化: 支払い情報のみ

Step 3: COPPA 準拠 (13才以下)
  └─ ユーザー年齢確認: 登録時に確認
  └─ 13才以下のプライバシー保護:
     ├─ 親の同意取得機能: 実装
     ├─ パーソナライズド広告: 制限
     ├─ 行動ターゲティング: 制限
     └─ 第三者データ共有: なし

Step 4: GDPR 準拠 (EU ユーザー)
  └─ データ主体の権利: 実装
  └─ データ保護影響評価: 実施
  └─ DPA with Third Parties: Google, Firebase等

Step 5: 日本個人情報保護法 準拠
  └─ 個人情報の定義: 法令に従う
  └─ 本人同意: 取得
  └─ 安全管理措置: 実施
  └─ 本人開示請求: 対応体制
  └─ FISC基準: クレジットカード情報セキュリティ
```

**Deadline:** Oct 1

**審査対応:**
```
Step 1: コンテンツレイティング Questionnaire
  └─ Category: Educational
  └─ Ratings:
     ├─ Violence: None
     ├─ Sexual Content: None
     ├─ Vulgarity: None
     ├─ Alcohol/Tobacco: None
     ├─ Gambling: None
     └─ Overall Rating: 3+ (全年齢)

Step 2: Restricted Content Declaration
  └─ Ads: Google Ads Network (Google Play Policies 準拠)
  └─ External Payment: なし (Google Play Billing のみ)
  └─ Sensitive Permissions: Camera (オプション), Microphone (オプション)

Step 3: Google Play Policy Compliance
  └─ Policy: Educational App Policy チェック
  └─ Items:
     ├─ Advertising: Google Play Policy準拠
     ├─ In-app Purchases: Google Play Billing必須
     ├─ Permissions: 必要最小限のみ
     ├─ App Stability: Crash rate < 1%
     └─ Performance: Start-up time < 3 seconds

Step 4: App Review Submission
  └─ Staging: Beta版 (Nov 1) → Limited Review
  └─ Production: 正式版 (Nov 26) → Full Review
  └─ Expected Review Time: 2-3時間 (Japan region)
  └─ Potential Issues: なし (事前チェック完了)
```

**Deadline:** Nov 1 (Beta), Nov 26 (Production)

### 2.5 ローンチスケジュール

**Beta版ローンチ (Nov 1):**
```
Step 1: Beta Track 設定
  └─ Testers: 1,000名 (内部テスト + 外部ベータ)
  └─ Rollout: 100% (すべてのテスターに配布)

Step 2: Beta版リリース
  └─ Release: Nov 1, 12:00 (JST)
  └─ Testing Period: Nov 1-26 (25日間)
  └─ Metrics:
     ├─ Crash Rate: < 0.5%
     ├─ ANR Rate: < 0.2%
     ├─ User Rating: > 4.0/5.0
     └─ Feedback: Critical issues は修正
```

**正式版ローンチ (Dec 1):**
```
Step 1: Production Track 設定
  └─ Release Type: Staged Rollout
  └─ Rollout Plan:
     ├─ Phase 1 (Dec 1, 0-5%): 初期段階テスト
     ├─ Phase 2 (Dec 1, 5-25%): 段階的拡大
     ├─ Phase 3 (Dec 2, 25-100%): 全体公開
     └─ Full Rollout Deadline: Dec 3 まで

Step 2: Production版リリース
  └─ Release: Dec 1, 12:00 (JST)
  └─ Target Users: 3M+ (Dec中に1M DAU目指す)
  └─ Expected Download: 1M+ (初日)
  └─ Metrics:
     ├─ Install Count: Track daily
     ├─ Uninstall Rate: < 5%
     ├─ Rating: > 4.0/5.0 maintain
     ├─ Crash Rate: < 0.5%
     └─ Server Load: Monitor 24/7
```

**Deadline:** Dec 1

---

## 3. iOS・Apple App Store セットアップ
### iOS & Apple App Store Release Preparation

### 3.1 Apple Developer Account

**アカウント設定:**
```
Step 1: Apple Developer Program
  └─ Enrollment Type: Organization (法人)
  └─ Verification: D-U-N-S Number取得 (法人識別番号)
  └─ Payment: $99/年 (Apple Developer Program)
  └─ Account Owner: CEO (法律上の責任者)

Step 2: Developer Account Details
  └─ Legal Entity Name: Safy Inc.
  └─ Address: 日本の登記住所
  └─ Contact: support@safy.jp
  └─ Phone: +81-XX-XXXX-XXXX

Step 3: Certificates, Identifiers & Profiles
  └─ Certificates:
     ├─ Development: 開発用コード署名証明書
     ├─ Distribution (App Store): 本番用署名証明書
     └─ Push Notification: APNs証明書 (本番)
  
  └─ Identifiers:
     ├─ App ID: jp.safy.ios (Bundle ID)
     ├─ Capabilities: Push Notifications有効化
     └─ Associated Domains: safy.jp

  └─ Provisioning Profiles:
     ├─ Development Profile: 開発端末署名用
     └─ Distribution Profile (App Store): 審査・配布用
```

**Deadline:** Sep 9

### 3.2 App Store Connect 設定

**アプリ登録:**
```
Step 1: App Information
  └─ App Name: Safy
  └─ Primary Language: Japanese
  └─ Bundle ID: jp.safy.ios
  └─ SKU: SAFY-001
  └─ Category: Education
  └─ Content Rights: Own content

Step 2: App Store Listing (日本語)
  └─ Subtitle (日本語): スキル習得オンラインプラットフォーム
  
  └─ Description:
     "Safyは、世界で求められるスキルを習得できるオンライン学習プラットフォーム。
     実務レベルのトレーニングで確実なキャリア成長を実現します。
     
     【特徴】
     • 実践的なカリキュラム
     • インタラクティブレッスン
     • コミュニティサポート
     • 修了証・認定資格
     • キャリアサポート"
  
  └─ Keywords: オンライン学習, スキル習得, キャリア, 教育
  
  └─ Preview (プレビュー動画):
     ├─ 長さ: 15-30秒
     ├─ 言語: 日本語
     └─ 解像度: 1080p

  └─ Screenshots:
     ├─ 解像度: 6.7インチ (iPhone 14 Pro Max)
     ├─ 数: 2-5枚
     ├─ 内容: ホーム・レッスン・プロジェクト・修了証
     └─ キャプション: 日本語で説明

  └─ App Icon:
     ├─ 解像度: 1024x1024px
     ├─ フォーマット: PNG
     └─ Content: Safy ロゴ

Step 3: App Review Information
  └─ Contact Information: support@safy.jp
  └─ Demo Account:
     ├─ Email: reviewer@safy.jp
     ├─ Password: (App Review用特別パスワード)
     └─ Account Level: Premium subscription active
  
  └─ Review Notes:
     "This is an educational app focused on skill acquisition.
     Demo account with premium content access is provided above.
     No external payment required (in-app purchases only).
     Content is purely educational with no inappropriate material."

Step 4: Version Information
  └─ Version Number: 1.0.0
  └─ Build Number: 1
  └─ Min iOS Version: 14.0
  └─ Max iOS Version: No limit
  └─ Supported Devices: iPhone, iPad
  └─ Supported Languages: Japanese, English

Step 5: Build Upload
  └─ Xcode: 15.0+
  └─ Build Command: xcode-build-app.sh
  └─ Upload: App Store Connect API
  └─ Notarization: Required (Apple security feature)
```

**Deadline:** Oct 1

### 3.3 iOS ビルド・署名

**ビルド準備:**
```
Step 1: Xcode Project Setup
  └─ Xcode Version: 15.0+
  └─ Build Settings:
     ├─ iOS Deployment Target: 14.0
     ├─ Architectures: arm64
     ├─ Code Signing: Apple Distribution
     └─ Provisioning Profile: App Store profile

Step 2: App Bundle ID & Signing
  └─ Bundle ID: jp.safy.ios
  └─ Team ID: (Apple Developer Team ID)
  └─ Signing Certificate: App Store Distribution
  └─ Provisioning Profile: App Store Deployment

Step 3: Build Archive
  └─ Command: xcodebuild archive -project Safy.xcodeproj...
  └─ Output: Safy.xcarchive
  └─ Verification: Code signing検証

Step 4: Export & Notarization
  └─ Export: Create .ipa from archive
  └─ Notarization: Apple サーバーに送信・検証
  └─ Stapling: Notarization ticket attach
  └─ Final: Notarized .ipa ready for upload
```

**Deadline:** Nov 26

### 3.4 TestFlight (Beta Testing)

**Beta版配布:**
```
Step 1: TestFlight Setup
  └─ Internal Testing Group: 開発チーム (29名)
  └─ External Testing Group: 選定ベータテスター (500-1000名)

Step 2: Build 配布
  └─ Build: 毎日更新 (September 9-November 25)
  └─ Internal Testers: 全員アクセス可
  └─ External Testers: App Review後に配布

Step 3: Feedback Collection
  └─ Tools: TestFlight feedback + Slack #ios-testing
  └─ Metrics:
     ├─ Crash Reports: Automatic collection
     ├─ Feedback: Manual submissions
     ├─ Usage Analytics: Testflight Dashboard
     └─ Performance: XCTest + Instruments

Step 4: Beta版リリース
  └─ Phase: Nov 1-26 (25日間)
  └─ Build Updates: 週2-3回
  └─ Target Issues: Critical and High bugs fix only
```

**Deadline:** Nov 26

### 3.5 App Store リリース

**正式版リリース:**
```
Step 1: Final Review Submission
  └─ Submission Date: Nov 26
  └─ Expected Review Time: 24-48時間
  └─ Release Date: Dec 1, 12:00 (JST) 予定

Step 2: Review Guidelines Compliance
  └─ Guideline: Apple App Store Review Guidelines
  └─ Categories:
     ├─ Safety: PII保護, スクリーン時間、セーフガード
     ├─ Performance: Stability, responsiveness
     ├─ Business: 支払い方法 (App Store In-App Purchase)
     ├─ Design: UI/UX基準
     └─ Content: 適切な教育コンテンツ

Step 3: Staged Rollout
  └─ Plan:
     ├─ Phase 1: 5% (Dec 1)
     ├─ Phase 2: 25% (Dec 2)
     ├─ Phase 3: 100% (Dec 3)
     └─ Full Rollout by: Dec 3, 23:59
  
  └─ Monitoring:
     ├─ Crash Rate: < 0.5%
     ├─ User Rating: Monitor daily
     ├─ Reviews: Respond to feedback
     └─ Update: Fix critical issues immediately
```

**Deadline:** Dec 1

---

## 4. Payment & Billing セットアップ
### Payment System Integration

### 4.1 Google Play Billing Library

**統合:**
```
Step 1: Google Play Billing Library インポート
  └─ Version: 6.0+ (Latest)
  └─ Gradle:
     ```gradle
     dependencies {
         implementation 'com.android.billingclient:billing:6.0.1'
     }
     ```

Step 2: BillingClient 初期化
  └─ Setup:
     ├─ startConnection()
     ├─ setListener() - PurchaseUpdatedListener
     ├─ enablePendingPurchases()
     └─ isFeatureSupported() - 機能確認

Step 3: SKU (商品ID) 設定
  └─ Subscription SKUs:
     ├─ safy.monthly.basic (月額980円)
     ├─ safy.yearly.basic (年額9800円)
     └─ safy.monthly.premium (月額2980円) [今後]
  
  └─ Configuration in Google Play Console:
     ├─ Pricing Tier: 0.99 USD 相当 (日本円)
     ├─ Renewal Period: Monthly / Yearly
     ├─ Free Trial: 7 days
     └─ Grace Period: 3 days (支払い遅延時)

Step 4: Purchase Flow 実装
  └─ Flow:
     1. querySkuDetailsAsync() - SKU詳細取得
     2. launchBillingFlow() - 購入画面表示
     3. PurchaseUpdatedListener - 購入結果受信
     4. acknowledgePurchase() - 購入確認
     5. queryPurchasesAsync() - 購入履歴確認
```

**Deadline:** Sep 11

### 4.2 Apple In-App Purchases

**統合:**
```
Step 1: StoreKit 2 統合 (Swift)
  └─ Framework: import StoreKit
  └─ Version: StoreKit 2 (iOS 15.0+)

Step 2: Product ID 設定
  └─ Product IDs in App Store Connect:
     ├─ jp.safy.monthly.basic
     ├─ jp.safy.yearly.basic
     └─ jp.safy.monthly.premium
  
  └─ Pricing Tier: 0.99 USD相当 (日本円)

Step 3: StoreKit Configuration
  └─ Code:
     ```swift
     async {
         do {
             products = try await Product.products(for: ["jp.safy.monthly.basic"])
             for product in products {
                 print("\(product.displayName) - \(product.displayPrice)")
             }
         } catch {
             print("Error fetching products: \(error)")
         }
     }
     ```

Step 4: Purchase Implementation
  └─ Flow:
     1. Fetch products - Product.products()
     2. Show purchase dialog - product.purchase()
     3. Verify transaction - Transaction.current
     4. Persist purchase - UserDefaults / Keychain
     5. Restore purchases - AppStore.sync()
```

**Deadline:** Sep 11

### 4.3 Test環境での支払いテスト

**Android:**
```
Step 1: Google Play Console - Internal Test Track
  └─ Release: Internal test build
  └─ Testers: developer@safy.jp 登録
  └─ Test Environment: Sandbox billing

Step 2: Test Account 設定
  └─ Google Play Console:
     ├─ Settings → Account → License Testing
     ├─ Add email: tester@safy.jp
     └─ License Test Status: 有効化

Step 3: Test Payment Scenario
  └─ 購入テスト:
     1. Safy アプリダウンロード (Internal Test track)
     2. サブスクリプション購入開始
     3. テスト用Google アカウント入力
     4. Payment Method: None (テスト用)
     5. 結果: 購入成功 (テスト環境)

Step 4: Verification
  └─ Receipt Token: サーバー送信検証
  └─ Acknowledgement: クライアント側で実施
  └─ Cancellation Test: キャンセル処理確認
```

**iOS:**
```
Step 1: Sandbox Tester Setup
  └─ App Store Connect:
     ├─ Users and Access → Sandbox → Testers
     ├─ Create Sandbox Apple ID: tester@safy-ios.jp
     └─ Password: (Temporary)

Step 2: StoreKit Transactions Testing
  └─ Xcode Test Environment:
     ├─ Use Xcode 15.0+ StoreKit test simulation
     ├─ Mock Products & Transactions
     └─ Test Scenarios:
        ├─ Successful purchase
        ├─ Pending transaction (親権者同意待ち)
        ├─ Failed transaction
        └─ Expired subscription renewal

Step 3: Sandbox Purchase Test
  └─ Process:
     1. Device: iPad / iPhone Simulator
     2. Signed in: Sandbox Tester Account
     3. Purchase: Subscription attempt
     4. Dialog: Sandbox environment warning
     5. Result: Purchase success in sandbox
     6. Refund: テスト用リンドから自動返金

Step 4: Receipt Verification
  └─ Server-side:
     ├─ Receipt Endpoint: sandbox.itunes.apple.com/verifyReceipt
     ├─ Bundle ID: jp.safy.ios
     └─ Verify Expiration Date & Renewal Status
```

**Deadline:** Oct 7

### 4.4 本番環境での支払い設定

**セキュリティ:**
```
Step 1: Backend Payment Verification
  └─ Payment Server (Node.js):
     ├─ Google Play Developer API
     │  └─ Verify receipt token via API
     │  └─ Check subscription status
     └─ Apple App Store Server API
        └─ Verify JWT transaction ID
        └─ Check subscription status

Step 2: Sensitive Data Protection
  └─ クレジットカード情報:
     ├─ クライアント側: 保存しない (Google/Apple に委託)
     ├─ サーバー側: トランザクションID & Status のみ保存
     ├─ Encryption: HTTPS only
     └─ PCI DSS: Not applicable (payments by Google/Apple)

Step 3: Fraud Detection
  └─ Monitoring:
     ├─ Unusual purchase patterns
     ├─ Refund rate monitoring (> 5% alert)
     ├─ Duplicate transaction detection
     └─ Velocity checks (複数購入の検出)

Step 4: Subscription Management
  └─ Features:
     ├─ Automatic renewal: Google/Apple管理
     ├─ Cancel subscription: User self-service
     ├─ Pause subscription: 実装予定
     └─ Restore purchases: Legacy support
```

**Deadline:** Nov 15

---

## 5. 本番運用セットアップ
### Production Operations Setup

### 5.1 監視・ロギング・アラート

**Cloud Operations (旧Stackdriver):**
```
Step 1: Firebase Crashlytics
  └─ Configuration:
     ├─ Enable: Automatic crash reporting
     ├─ Symbols: Upload dSYM (iOS) & Symbols (Android)
     ├─ Alerts: Critical crash > 1件でアラート
     └─ Dashboard: Real-time crash overview

Step 2: Firebase Performance Monitoring
  └─ Metrics:
     ├─ App Start Time: < 2秒 (target)
     ├─ Screen Render: < 16ms (60 FPS)
     ├─ HTTP Latency: < 200ms (API)
     ├─ Custom Traces: Payment flow, login
     └─ Thresholds: Baseline達成を監視

Step 3: Cloud Logging
  └─ Logs:
     ├─ Application Logs: Firebase Functions から
     ├─ API Request Logs: Google Cloud Load Balancer から
     ├─ Database Logs: Firestore audit logs
     ├─ Security Logs: Authentication & Authorization
     └─ Error Logs: Stack traces & error messages
  
  └─ Log Retention: 30日 (本番)
  └─ Log Queries: BigQuery export

Step 4: Alerting
  └─ Alert Policies:
     ├─ Crash Rate > 1%: Page Tech Lead
     ├─ API Error Rate > 5%: Page Infra Lead
     ├─ Database Errors > 10: Page DBA
     ├─ Payment Failures > 5: Page Finance Lead
     ├─ Server Load > 80%: Page Infra
     └─ Storage > 80% full: Page Infra
  
  └─ Escalation:
     ├─ Level 1: Auto-page oncall engineer
     ├─ Level 2 (15min): Page team lead
     ├─ Level 3 (30min): Page manager
     ├─ Level 4 (1hour): Page CEO
```

**Deadline:** Oct 15

### 5.2 バックアップ・復旧

**Backup Strategy:**
```
Step 1: Firestore Backup
  └─ Frequency: Daily (00:00 JST)
  └─ Retention: 30 days
  └─ Location: asia-northeast1 + us-central1 (DR)
  └─ Size: < 1GB (estimated)

Step 2: Cloud Storage Backup
  └─ Bucket: safy-production-primary-storage
  └─ Backup: Daily snapshot to backup bucket
  └─ Retention: 7 days (recent) + Monthly archive
  └─ Verification: Monthly restore test

Step 3: Database Export
  └─ BigQuery Export:
     ├─ Tables: Daily export to BigQuery
     ├─ Retention: 90 days
     ├─ Frequency: Daily 01:00 JST
     └─ Purpose: Analytics & reporting

Step 4: Disaster Recovery Test
  └─ Schedule: Quarterly (Sep, Dec, Mar, Jun)
  └─ Scenario: Full production recovery
  └─ Target RTO: 4 hours
  └─ Target RPO: 24 hours
  └─ Validation: Full functionality check
```

**Deadline:** Oct 7

### 5.3 インシデント対応 & ホットライン

**24x7 Support:**
```
Step 1: On-Call Schedule
  └─ Engineers: Backend Lead, Frontend Lead, Infra Lead
  └─ Rotation: 1 week per person
  └─ Escalation: Tech Lead → Dev Manager → CEO
  └─ Notification: SMS + Push + Email

Step 2: Incident Response Process
  └─ Severity Levels:
     ├─ P1 (Critical): Payment down, Data loss, > 1M users affected
     │  └─ Response: < 5分
     │  └─ Page: CEO + All leads
     └─ P2 (High): Major feature down, > 100K users affected
        └─ Response: < 30分
        └─ Page: Oncall engineer + Team lead

Step 3: Communication
  └─ Slack Channels:
     ├─ #incident-response (internal)
     ├─ #status-page (public updates)
     └─ #war-room (real-time coordination during incident)
  
  └─ Status Page: https://status.safy.jp
     ├─ Real-time incident updates
     ├─ ETA for resolution
     └─ Post-incident analysis link

Step 4: Runbooks
  └─ Common Incidents:
     ├─ Payment service down: Failover to backup processor
     ├─ Database slow: Query optimization + cache clear
     ├─ Crash spike: Disable new feature + rollback
     ├─ DDoS attack: CloudFlare mitigation
     └─ Data corruption: Restore from backup
```

**Deadline:** Oct 15

---

## 6. マーケティング・リリース計画
### Marketing & Launch Plan

### 6.1 プリローンチ (Sep 8 - Oct 31)

**フェーズ 1: Team Announcement (Sep 8-11)**
```
Step 1: Board Approval (Sep 8)
  └─ Board vote: YES → Board members informed

Step 2: Team Announcement (Sep 8, 12:05 PM)
  └─ Target: 全Safy チーム 42名
  └─ Message: $2.5M投資決定 + Dec 1本番ローンチ計画
  └─ Channel: All-hands meeting + Slack announcement

Step 3: Leader Briefing (Sep 8, 1:00-2:00 PM)
  └─ Audience: Tech Lead, Product Lead, Finance Lead, Marketing Lead
  └─ Content: 詳細ローンチ計画, チーム分担, リスク

Step 4: All-Hands Celebration (Sep 8, 2:00-3:00 PM)
  └─ Audience: 全員
  └─ Message: We're going to launch!
  └─ Timeline: December 1, 2026
```

**フェーズ 2: Influencer Outreach (Oct 1-15)**
```
Step 1: Influencer List Finalization
  └─ Categories:
     ├─ Tech Education (YouTube, TikTok): 10-20 people
     ├─ Career Development (LinkedIn): 5-10 people
     ├─ General Education: 5 people
  
  └─ Criteria:
     ├─ Followers: > 100K (Japan)
     ├─ Engagement Rate: > 3%
     ├─ Audience Match: 18-35 age group
     └─ Brand Alignment: Education + Career focus

Step 2: Partnership Proposals
  └─ Content:
     ├─ Exclusive early access (Nov 1)
     ├─ Promo code: INFLUENCER20 (20% discount)
     ├─ Revenue share: TBD per influencer
     └─ Deliverables: 3-5 posts (launch + 2 weeks)

Step 3: Deal Closing
  └─ Deadline: Oct 15
  └─ Confirmed: 20+ influencers

Step 4: Content Calendar Planning
  └─ Timeline:
     ├─ Oct 20-31: Teasers (hype building)
     ├─ Nov 1-30: Launch + regular posts
     └─ Dec 1-31: Continued promotion
```

**フェーズ 3: Pre-Launch Campaign (Oct 1-31)**
```
Step 1: Website Update
  └─ safy.jp:
     ├─ Waitlist signup: Early access for first 10K users
     ├─ "Coming Dec 1": Banner + countdown
     ├─ Features overview: Product benefits
     └─ Join community: Discord/Slack invitation

Step 2: Email Campaign
  └─ Sequence:
     ├─ Oct 1: Launch announcement (existing users)
     ├─ Oct 15: Feature highlights
     ├─ Oct 29: Last chance for early access
     └─ Dec 1: Now available on App Store/Play Store
  
  └─ Segments: Waitlist, beta testers, email subscribers

Step 3: Paid Advertising
  └─ Channels:
     ├─ Google Ads (Search): Target "Learn [skill]"
     ├─ YouTube Ads: 15-30 second unskippable
     ├─ TikTok Ads: Native format (15-60 seconds)
     └─ Meta Ads (Facebook/Instagram): Carousel format
  
  └─ Budget: $20K/month (Oct-Nov)
  └─ Target: CPM $5-10, Conversion Rate > 5%

Step 4: PR & Media Outreach
  └─ Targets:
     ├─ TechCrunch Japan
     ├─ Forbes Japan
     ├─ EdTechWave
     ├─ Startup media
     └─ Business press
  
  └─ Messaging: "$2.5M-funded education startup launches"
  └─ Embargo: Lift Dec 1, 12:00
```

### 6.2 ローンチ (Nov 1 - Dec 1)

**Phase 1: Soft Launch (Nov 1)**
```
Step 1: Beta Release
  └─ Channels:
     ├─ Google Play: Beta track (1,000 testers)
     └─ TestFlight: iOS (500 testers)

Step 2: Influencer Launch Wave 1
  └─ Timing: Nov 1, 12:00 JST
  └─ Posts: All influencers simultaneously
  └─ Message: "Safy is live - get early access"
  └─ Expected Reach: 5M+ impressions

Step 3: Community Activation
  └─ Channels:
     ├─ Discord: Launch celebration
     ├─ Slack: Tech community announcements
     ├─ Reddit: r/learnprogramming, r/education
     └─ Twitter/X: Thread + updates

Step 4: Metrics Target
  └─ Nov 1-7:
     ├─ New users: 50K+
     ├─ Conversion rate: > 5%
     ├─ Rating: > 4.0/5.0
     ├─ Crash rate: < 0.5%
     └─ Support tickets: < 50/day
```

**Phase 2: Hard Launch (Dec 1)**
```
Step 1: Production Release
  └─ Timing: Dec 1, 12:00 JST
  └─ Channels:
     ├─ Google Play: Full release (100% rollout by Dec 3)
     ├─ Apple App Store: Full release
     ├─ Website: Direct link to app stores
     └─ Email: All waitlist users + newsletters

Step 2: Marketing Blitz
  └─ Channels:
     ├─ All influencers: 2nd wave of posts
     ├─ Paid ads: Budget increase to $50K/day
     ├─ PR: Press release distribution
     ├─ Community: Community events & Q&A
     └─ Partnerships: Collaborations with education platforms

Step 3: 24-hour operations (Dec 1, 12:00 - Dec 2, 12:00)
  └─ Metrics Monitoring (30-min cadence):
     ├─ Server load & CPU usage
     ├─ Database performance
     ├─ API latency
     ├─ Error rates
     ├─ Crash reports
     ├─ User acquisition rate
     ├─ Payment conversion rate
     └─ Support ticket volume
  
  └─ Target Metrics (Dec 1-7):
     ├─ New registrations: 500K+
     ├─ Paid conversions: 50K+ (10% conversion)
     ├─ DAU: 200K+ (by Dec 7)
     ├─ Rating: 4.0-4.5/5.0
     ├─ Retention (D1): 40%+
     └─ Crash rate: < 1%

Step 4: Success Celebration
  └─ All-Hands Meeting: Dec 1, 15:00 JST
  └─ Message: We did it! From board vote to public launch.
  └─ Next milestone: 1M DAU by Dec 31
```

---

## 7. 本番ローンチ前チェックリスト
### Pre-Launch Verification Checklist

**Sep 15: GATE 2 検証**
```
Firebase Production:
□ Firestore collections created & indexes built
□ Cloud Storage buckets created & CDN enabled
□ Cloud Functions deployed & tested
□ FCM topics created & configured
□ Analytics events tracking correctly
□ Crashlytics receiving crashes
□ Remote Config parameters set
□ Backup schedule enabled & tested
□ Security rules deployed & tested
□ Service accounts configured for API calls
```

**Oct 1: Google Play準備**
```
Google Play Console:
□ App listing completed (Japanese)
□ Screenshots & media uploaded (all 8 formats)
□ Feature image & preview video ready
□ Privacy policy linked & compliant
□ Data safety form completed
□ Content rating questionnaire answered
□ APK/AAB signing configured
□ Internal test track ready with signed APK
□ Beta testers invited (100+)
```

**Oct 1: iOS準備**
```
Apple App Store Connect:
□ App information completed
□ Screenshots for all device sizes
□ Preview video uploaded
□ Privacy policy & data practice compliant
□ Demo account created for reviewers
□ Certificates & provisioning profiles valid
□ Build signed & notarized
□ TestFlight internal testers invited
```

**Oct 7: Payment準備**
```
Google Play Billing:
□ SKU配置 (monthly & yearly subscriptions)
□ Pricing set (¥980/月, ¥9800/年)
□ Free trial (7 days) configured
□ Test account created & payment tested
□ Receipt verification working on server

Apple In-App Purchases:
□ Product IDs created
□ Pricing set (same as Android)
□ Sandbox tester account created
□ StoreKit 2 implementation tested
□ Receipt verification working on server
```

**Oct 15: 運用準備**
```
Monitoring & Alerting:
□ Firebase Crashlytics configured
□ Performance Monitoring set up
□ Cloud Logging configured
□ Alert policies created & tested
□ On-call schedule set up
□ Incident response runbooks created
□ Status page deployed
□ Backup & restore procedures tested

Support Infrastructure:
□ Support email (support@safy.jp) active
□ Helpdesk system (Zendesk) configured
□ Support team trained
□ FAQ documentation ready
□ Common issues troubleshooting guide
```

**Nov 1: Beta Launch準備**
```
Beta Testing:
□ Internal testers (29 dev team) invited to TestFlight/Beta
□ External testers (500-1000) selected & invited
□ Feedback collection mechanism set up
□ Known issues list created & updated daily
□ Hotfix process prepared for beta issues

Pre-Launch Marketing:
□ Influencer partnerships finalized (20+)
□ Paid advertising campaigns ready (Oct 1 start)
□ PR pitches sent to media
□ Community announcements prepared
□ Email campaign sequenced
```

**Nov 26: GATE 5 検証**
```
Final Production Readiness:
□ All beta testing complete
□ Critical & high bugs: 0 remaining
□ Medium bugs: < 5 with workarounds
□ Test coverage: 90%+
□ Crash rate on beta: < 0.5%
□ User rating on beta: 4.0+/5.0
□ Deployment rehearsal: 2+ successful runs
□ Rollback procedure: Tested & verified
□ Database: Production data migrated
□ API endpoints: Load tested (5000+ concurrent users)
□ CDN: Configured & tested
□ Monitoring: All dashboards live
□ Support team: Trained & ready
□ 24-hour war room: Set up & staffed
```

**Dec 1: Launch Day準備**
```
Go-Live Checklist:
□ All engineers on standby (12:00 JST - 12:00 JST +24h)
□ Slack war room active
□ Status page ready for updates
□ Database backups: Recent & verified
□ API servers: Warmed up & load-balanced
□ CDN: All assets cached
□ Payment processors: Ready & tested
□ Support team: 3 shifts arranged (20 agents)
□ Marketing team: Ready for announcements
□ Influencers: Posts scheduled & verified
□ Email campaigns: Queued & ready to send
□ Real-time monitoring: All dashboards active
```

---

## 8. 実装タイムライン
### Implementation Timeline

```
Sep 4: This document created
Sep 9: Dev team registration begins
  └─ Firebase dev environment setup complete
  └─ Google Play Console account created
  └─ Apple Developer account created
  
Sep 11: Core platform development
  └─ Firestore staging environment ready
  └─ Cloud Functions deployed
  └─ Payment billing libraries integrated
  
Sep 15: GATE 2 検証
  └─ Firebase production environment 70% ready
  └─ API endpoints fully implemented & tested
  
Oct 1: Marketing & Store Listing
  └─ Google Play listing complete
  └─ Apple App Store Connect ready
  └─ Screenshots & media finalized
  └─ Paid advertising campaigns start
  
Oct 7: Payment & Operations
  └─ Firebase production environment complete
  └─ Payment testing on both platforms
  └─ Backup & monitoring infrastructure
  └─ On-call schedule live
  
Oct 15: Beta Test Preparation
  └─ All systems staging-tested
  └─ Internal testers (dev team) ready
  └─ Influencer partnerships confirmed
  
Nov 1: Beta Release (Soft Launch)
  └─ Google Play beta track live (1K testers)
  └─ TestFlight live (500 iOS testers)
  └─ Influencer wave 1 posts live
  └─ Metrics: 50K new users target
  
Nov 26: GATE 5 検証
  └─ All beta issues resolved
  └─ Final load testing passed
  └─ Production launch checklist 100%
  
Dec 1: Hard Launch (Production)
  └─ Google Play & Apple App Store: LIVE
  └─ Staged rollout: 100% by Dec 3
  └─ 24-hour war room active
  └─ Target: 500K+ new users on day 1
  
Dec 7: Post-Launch Review
  └─ Metrics assessment
  └─ Issues remediation
  └─ Lessons learned documentation
```

---

## 9. 成功メトリクス
### Success Metrics

### Firebase & Technical

```
Stability:
✓ Uptime: 99.9%+ (目標)
✓ Crash rate: < 0.5% (acceptable limit)
✓ Error rate: < 1% (API requests)
✓ Latency p99: < 500ms (API calls)

Performance:
✓ App startup: < 3秒 (4G)
✓ Screen render: < 16ms (60 FPS)
✓ Payment processing: < 2秒
✓ Search query: < 500ms

Security:
✓ Critical/High vulnerabilities: 0
✓ Data encryption: 100%
✓ HTTPS usage: 100%
✓ Unauthorized access attempts: 0
```

### User Acquisition & Monetization

```
Registration:
✓ Dec 1-7: 500K+ new registrations
✓ Dec 1-31: 1M+ total registrations
✓ D1 retention: > 40%
✓ D7 retention: > 20%

Monetization:
✓ Paid conversion rate: > 10%
✓ ARPU (first month): ¥3000+
✓ Churn rate: < 5%/month (subscription)
✓ LTV/CAC ratio: > 6:1

Engagement:
✓ DAU/MAU ratio: > 20%
✓ Avg session length: > 10分
✓ Content completion rate: > 50%
✓ Rating (App Stores): 4.0+/5.0
```

---

**ドキュメント完成:** Google・Firebase公開ローンチ完全準備ガイド (1500+ 行)  
**最終確認:** Tech Lead + DevOps Lead + Marketing Lead  
**配布:** 全チーム + ステークホルダー  

This comprehensive guide covers every aspect of Firebase, Google Play Store, and Apple App Store preparation for the Dec 1, 2026 public launch of Safy.
