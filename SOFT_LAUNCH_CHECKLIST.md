# ソフトローンチ チェックリスト（設計書 Step6.5）

安心企業研修Safyのクローズドβ（自社/知人企業 3〜5社・50〜100アカウント規模）
実施前後で確認する項目。批判的レビュー（⭐2.5/5、project_safy.md参照）を踏まえ、
特にチャネル・スコープの検証を重視する。

## A. 実施前の技術的前提条件
- [ ] Firebase Console本設定完了（[flutter-firebase-setup]スキル参照）
- [ ] `flutterfire configure` 実行、`firebase_options.dart` 生成、main.dartにFirebase.initializeApp()追加
- [ ] `safy/firestore.rules` をFirebase Consoleへデプロイ
- [ ] Cloud Functions `submitQuizAttempt` をデプロイ（QuizService.submitAttemptの本経路）
- [ ] `bin/seed_firestore.dart` 実行（業種8/モジュール18/レッスン54/クイズ108問の投入）
- [ ] Cloud Functions `sendMonthlyReports` 用のSecret設定（`firebase functions:secrets:set SENDGRID_API_KEY`・`SENDGRID_FROM_EMAIL`、SendGridで送信元認証済みのアドレス）
- [ ] RevenueCat設定・課金動線の実機確認
- [ ] 実機ビルド（[build-flutter-apk]）・[flutter-device-test]スキルでのスモークテスト
- [ ] J-PlatPat商標検索でタイトル「Safy」の国内商標リスクを確認（設計書1-C参照、未実施）

## B. ゲート条件（設計書Step6.5より）
クローズドβ終了時、以下を満たしてから本公開判断を行う。

- [ ] 管理者の週1回以上ログイン率 50%+
- [ ] 従業員側Aha到達率（チームID入力→1テーマ受講完了） 60%+
- [ ] クラッシュフリー率 99.5%+
- [ ] 業種プロファイルの精度を実データで検証（誤った優先度表示がないか）

## C. 批判的レビュー（project_safy.md参照）への対応状況
- [ ] MVPスコープ縮小の検討（「単一業種・単一カテゴリ・最大20名企業向け」への絞り込み方針、未実施）
- [ ] チャネル戦略の具体化（商工会議所・社労士/中小企業診断士経由 or 直販、Month1で具体化必須とされていた項目）
- [ ] 年次更新研修の制度化（ISMS/Pマーク年1回受講要件との連動、継続コンテンツ量を補う施策）

## D. 参加企業ごとの確認事項
- [ ] 会社プロファイル登録（業種選択）
- [ ] チーム作成・招待コード発行
- [ ] 従業員招待（最低1名は実際に受講完了まで確認）
- [ ] 管理者ダッシュボードでの受講率確認・チーム別受講率比較画面の表示確認
- [ ] レポート出力（PDF/CSV）が正しく生成されるか
- [ ] 従業員の修了証PDFダウンロードが正しく生成されるか

## E. 本公開前の最終確認
- [ ] プライバシーポリシー確定・公開（PRIVACY_POLICY.mdのドラフトを法務確認の上で確定）
- [ ] ストア掲載文確定・スクリーンショット実機撮影（STORE_LISTING.md参照）
- [ ] [flutter-play-release]スキルに沿った署名・AAB生成
- [ ] [flutter-qa-checklist]スキルでの全画面QA実施
