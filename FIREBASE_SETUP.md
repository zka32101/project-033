# Firebase Console 設定手順

安心企業研修Safyは以下のFirebase機能に依存している（`pubspec.yaml`参照）：
Authentication（匿名認証）／Firestore／Cloud Functions／Analytics／Crashlytics／
Remote Config／Cloud Messaging（プッシュ通知）。

現時点ではFirebase Console側の設定が未完了のため、`lib/main.dart`は
`Firebase.initializeApp()`を呼んでいない（呼ぶと即例外になるため意図的に未実装）。
本ドキュメントはその設定を完了させるための手順。完了後の最終確認は
`SOFT_LAUNCH_CHECKLIST.md`のセクションAを参照。

## 0. 事前準備（ローカル環境）

- [ ] Node.js がインストール済み（Firebase CLIの実行に必要）
- [ ] Firebase CLI をインストール: `npm install -g firebase-tools`
- [ ] FlutterFire CLI をインストール: `dart pub global activate flutterfire_cli`
- [ ] `firebase login` でGoogleアカウントにログイン

## 1. Firebaseプロジェクトを作成

1. [Firebase Console](https://console.firebase.google.com/) で新規プロジェクトを作成
2. Google Analytics の有効化を選択（`firebase_analytics`を使用しているため推奨）
3. リージョンは後述のFirestore作成時に選択（東京: `asia-northeast1`推奨）

## 2. アプリを登録

アプリのID/バンドルIDは以下の通り、リポジトリの設定と**必ず一致させる**こと。

| プラットフォーム | ID |
|---|---|
| Android パッケージ名 | `com.yourwish.safy`（`android/app/build.gradle.kts`の`applicationId`） |
| iOS バンドルID | `com.yourwish.safy`（Xcodeの`PRODUCT_BUNDLE_IDENTIFIER`） |

- [ ] Android アプリを登録し、`google-services.json`をダウンロードして
      `android/app/google-services.json`に配置（`.gitignore`済みなので各自配置）
- [ ] iOS アプリを登録し、`GoogleService-Info.plist`をダウンロードして
      `ios/Runner/GoogleService-Info.plist`に配置（同上）
- [ ] iOS: Apple Developer PortalでAPNs認証キー(.p8)を発行し、
      Firebase Console → プロジェクト設定 → Cloud Messaging → iOS アプリ設定 にアップロード
      （プッシュ通知に必須。これが無いとiOS実機でFCMが機能しない）

## 3. FlutterFire CLIで`firebase_options.dart`を生成

リポジトリのルートで実行:

```bash
flutterfire configure --project=<firebase-project-id>
```

対話式でAndroid/iOS/(必要なら)Webのプラットフォームを選択すると、
`lib/firebase_options.dart`が自動生成される（このファイルは`.gitignore`対象外な
ので生成後はそのままコミットしてよい。APIキーはクライアント埋め込み前提の
公開情報であり、実際のアクセス制御はFirestoreセキュリティルール側で行う）。

## 4. `main.dart`にFirebase初期化を追加

生成後、`lib/main.dart`を以下のように変更する（現在は意図的にコメントアウトされている）。

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SafyApp()));
}
```

`bin/seed_firestore.dart`側も同様に、ファイル冒頭のコメント指示に従い
`import`のコメントを解除し`Firebase.initializeApp(options: ...)`に差し替える。

- [ ] `main.dart`を上記のように変更
- [ ] `bin/seed_firestore.dart`を上記のように変更
- [ ] `flutter analyze` / `flutter test` がエラーなく通ることを確認

## 5. Authentication設定

- [ ] Console → Authentication → Sign-in method → **匿名(Anonymous)を有効化**

> **重要**: 本アプリは`EmployeeService`が`signInAnonymously()`のみを使う設計。
> メール/パスワード等の他方式は不要。
>
> なお`lib/services/auth_service.dart`（`AuthService`クラス）はメール/パスワード認証
> 前提の実装だが、アプリ内のどの画面からも呼ばれていない未使用コード
> （実際のスキーマ`companies/{companyId}/employees/{employeeId}`とも異なる、
> 別設計時期の残骸と見られる）。これを見て「メール/パスワード認証が必要」と
> 誤解しないよう注意。不要なら削除を推奨（別途対応可能）。

## 6. Firestore Database

- [ ] Console → Firestore Database → データベースを作成（本番モード、リージョンは
      東京`asia-northeast1`推奨）
- [ ] セキュリティルールをデプロイ:
  ```bash
  firebase deploy --only firestore:rules
  ```
  （リポジトリ直下の`firebase.json`が`firestore.rules`を参照する設定を含んでいる。
  未接続の場合は先に`firebase use --add`でこのプロジェクトを紐付けること）

## 7. Cloud Functionsのデプロイ

デプロイ対象(`functions/src/index.ts`): `submitQuizAttempt`（クイズ採点・改ざん防止の要）、
`onReminderCreated`（個別リマインド通知）、`checkModuleDeadlinesAndNotify`（期限通知・毎日9時JST）、
`sendMonthlyReports`（前月分レポートメール送信・毎月1日9時JST）、
`generateOriginalContent`（プレミアムプラン向けオリジナルコンテンツAI生成、Claude API使用）。

- [ ] Node.js 20系がインストール済みであること（`functions/package.json`の`engines.node`指定）
- [ ] `sendMonthlyReports`用にSendGridのSecretを設定:
  ```bash
  firebase functions:secrets:set SENDGRID_API_KEY
  firebase functions:secrets:set SENDGRID_FROM_EMAIL
  ```
  （`SENDGRID_FROM_EMAIL`はSendGrid側で送信元認証済みのアドレスであること）
- [ ] `generateOriginalContent`用にAnthropicのSecretを設定:
  ```bash
  firebase functions:secrets:set ANTHROPIC_API_KEY
  ```
  （[console.anthropic.com](https://console.anthropic.com/)で発行したAPIキー。
  このSecretが無いとオリジナルコンテンツのAI生成機能のみデプロイ・実行に失敗する
  ―他の関数には影響しない）
- [ ] Blazeプラン（従量課金）へのアップグレード（Cloud FunctionsはSparkプランでは
      デプロイ不可）
- [ ] ビルド・デプロイ:
  ```bash
  cd functions && npm install && npm run build && cd ..
  firebase deploy --only functions
  ```

## 8. 初期データ投入

- [ ] ステップ4完了後、種データ(業種8/モジュール24/レッスン72/クイズ144問)を投入:
  ```bash
  dart run bin/seed_firestore.dart
  ```
  冪等なので複数回実行しても重複は発生しない。

## 9. Remote Config

- [ ] Console → Remote Config でパラメータを作成し、`RemoteConfigService`の
      デフォルト値と合わせて初期値を設定:
      - `min_supported_version`（強制アップデート判定用。初期値は現行バージョンでよい）
      - `audit_log_feature_enabled`（true）
      - `ranking_feature_enabled`（true）
      未設定でもコード側のデフォルト値で動作するため、必須ではなくLiveOps用の任意設定。

## 10. Analytics / Crashlytics

- [ ] Analytics: ステップ1でGoogle Analyticsを有効化していれば追加設定不要
      （`AnalyticsService`経由でアプリから自動送信される）
- [ ] Crashlytics: **現状コード側で初期化されていない**（`firebase_crashlytics`は
      依存関係に含まれるが`lib/`内のどこからも呼ばれていない）。Console側で
      有効化するだけでは収集されないため、実際にクラッシュレポートが必要な場合は
      別途`main.dart`への組み込み（`FlutterError.onError`/`PlatformDispatcher.onError`
      → `FirebaseCrashlytics.instance.recordFlutterFatalError`等）が必要。

## 11. 動作確認

- [ ] `flutter run`で実機/エミュレータ起動し、個人登録 or 招待コード参加ができること
- [ ] 管理者としてモジュール受講期限を設定し、[flutter-device-test]スキル等で
      プッシュ通知が実機に届くこと（`checkModuleDeadlinesAndNotify`は日次実行なので
      即時確認したい場合はCloud Functionsコンソールから手動トリガーするか、
      Firebase Emulator Suiteでのテストを検討）
- [ ] クイズ提出→`submitQuizAttempt`経由で採点・合否判定・修了証発行がされること
- [ ] 管理者ダッシュボード→「オリジナルコンテンツ管理」→プレミアムプラン契約後、
      テーマ入力→AI生成→保存→社員側ホーム画面にオリジナルモジュールが表示されること

---

Firebase以外に必要な外部サービス設定（RevenueCat決済動線等）は
`SOFT_LAUNCH_CHECKLIST.md`セクションAを参照。
