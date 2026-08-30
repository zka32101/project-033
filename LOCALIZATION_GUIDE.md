# Safy 多言語対応ガイド | Localization Guide

## 概要 | Overview

Safyアプリは、Flutter の公式ローカライゼーション機能を使用して複数言語をサポートしています。
現在、以下の言語をサポートしています：

- 🇯🇵 日本語 (Japanese)
- 🇺🇸 英語 (English)
- 🇨🇳 中国語簡体字 (Simplified Chinese)
- 🇰🇷 韓国語 (Korean)

---

## プロジェクト構造 | Project Structure

```
lib/
├── l10n/                          # ローカライゼーションファイル
│   ├── app_ja.arb                 # 日本語翻訳
│   ├── app_en.arb                 # 英語翻訳
│   ├── app_zh.arb                 # 中国語翻訳
│   └── app_ko.arb                 # 韓国語翻訳
├── providers/
│   └── localization_provider.dart  # 言語管理プロバイダー
├── extensions/
│   └── localization_extension.dart # ローカライゼーション拡張
├── widgets/
│   └── language_selector.dart      # 言語選択ウィジェット
└── main.dart                       # アプリエントリーポイント

l10n.yaml                           # ローカライゼーション設定ファイル
pubspec.yaml                        # 依存関係
```

---

## セットアップ手順 | Setup Instructions

### 1. ローカライゼーション ファイルの生成

ローカライゼーション ファイルを生成するには、以下のコマンドを実行します：

```bash
flutter gen-l10n
```

このコマンドにより、以下のファイルが自動生成されます：
- `lib/generated/app_localizations.dart`
- `lib/generated/app_localizations_*.dart` (各言語ごと)

> **注意**: `lib/generated/` フォルダは `.gitignore` に追加されています。
> ビルド時に自動生成されるため、手動で編集しないでください。

### 2. 依存関係の確認

`pubspec.yaml` に以下が含まれていることを確認してください：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

dev_dependencies:
  # その他の dev dependencies...
```

---

## 使用方法 | Usage

### ウィジェット内での文字列の取得

**方法1: BuildContextの拡張を使用（推奨）**

```dart
import 'package:flutter/material.dart';
import 'extensions/localization_extension.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.common_welcome);  // 「いらっしゃいませ」
  }
}
```

**方法2: AppLocalizationsを直接使用**

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.common_welcome);
  }
}
```

### 言語の変更

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/localization_provider.dart';

// コンポーネント内
final notifier = ref.read(localizationProvider.notifier);

// 言語を変更
await notifier.setLocaleFromEnum(SupportedLocale.en);
// または
await notifier.setLocale(Locale('en', 'US'));
```

### 言語選択ウィジェットの使用

**完全な言語選択パネル**

```dart
import 'widgets/language_selector.dart';

LanguageSelector(
  showTitle: true,
  // オプション: onChanged コールバック
)
```

**ドロップダウン言語選択**

```dart
import 'widgets/language_selector.dart';

LanguageDropdown(
  onChanged: (locale) {
    // 言語が変更されたときの処理
    print('Language changed to: ${locale.displayName}');
  },
)
```

---

## 新しい言語の追加 | Adding a New Language

### ステップ1: 翻訳ファイルの作成

新しい言語（例：スペイン語）を追加する場合：

1. `lib/l10n/` フォルダに `app_es.arb` ファイルを作成
2. テンプレートとして `app_en.arb` をコピー
3. すべての文字列をスペイン語に翻訳

```json
{
  "@@locale": "es",
  "appTitle": "Safy - Capacitación Corporativa Segura",
  "common_welcome": "Bienvenido",
  ...
}
```

### ステップ2: ローカライゼーション設定を更新

`l10n.yaml` を編集して新しい言語を追加：

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/generated
preferred-supported-locales:
  - ja
  - en
  - zh
  - ko
  - es  # 新しい言語を追加
```

### ステップ3: プロバイダーを更新

`lib/providers/localization_provider.dart` を編集して新しい言語を追加：

```dart
enum SupportedLocale {
  ja(Locale('ja', 'JP'), '日本語'),
  en(Locale('en', 'US'), 'English'),
  zh(Locale('zh', 'CN'), '简体中文'),
  ko(Locale('ko', 'KR'), '한국어'),
  es(Locale('es', 'ES'), 'Español'),  // 新しい言語を追加
  // ...
}
```

### ステップ4: ウィジェットを更新

言語選択ウィジェット内の `_getFlagEmoji` メソッドを更新：

```dart
String _getFlagEmoji(SupportedLocale locale) {
  switch (locale) {
    case SupportedLocale.ja:
      return '🇯🇵';
    case SupportedLocale.en:
      return '🇺🇸';
    case SupportedLocale.zh:
      return '🇨🇳';
    case SupportedLocale.ko:
      return '🇰🇷';
    case SupportedLocale.es:
      return '🇪🇸';  // 新しい言語用のフラグ絵文字を追加
  }
}
```

### ステップ5: ファイルを生成

```bash
flutter gen-l10n
```

---

## 文字列の追加・更新 | Adding/Updating Strings

### 新しい文字列の追加

すべての `.arb` ファイルに新しいキーと値を追加してください：

**app_ja.arb:**
```json
{
  "newFeature_title": "新機能"
}
```

**app_en.arb:**
```json
{
  "newFeature_title": "New Feature"
}
```

**app_zh.arb:**
```json
{
  "newFeature_title": "新功能"
}
```

**app_ko.arb:**
```json
{
  "newFeature_title": "새로운 기능"
}
```

その後、ファイルを生成します：

```bash
flutter gen-l10n
```

### 文字列の使用

```dart
Text(context.l10n.newFeature_title)
```

---

## ベストプラクティス | Best Practices

### 1. 一貫性のあるキー命名

- プレフィックスを使用してカテゴリーを示す
  - `auth_` - 認証関連
  - `quiz_` - クイズ関連
  - `course_` - コース関連
  - `common_` - 共通文字列
  - `error_` - エラーメッセージ

### 2. ARBファイルの構成

- ファイルの先頭に `@@locale` を記載
- 関連する文字列を互いに近くに配置
- ロジカルなグループを作成

### 3. 長い文字列のフォーマット

```json
{
  "longDescription": "これは非常に長い説明です。複数行にわたる場合があります。"
}
```

### 4. プレースホルダーの使用

ARBフォーマットはICUメッセージフォーマットをサポートしています：

```json
{
  "greeting": "こんにちは、{name}さん"
}
```

ウィジェット内での使用：

```dart
AppLocalizations.of(context)!.greeting(name: 'Taro')
```

---

## 一般的な問題のトラブルシューティング | Troubleshooting

### 問題: 生成されたファイルが見つからない

**解決方法:**
```bash
flutter pub get
flutter gen-l10n
```

### 問題: 言語が変更されない

**チェック項目:**
- `main.dart` が正しく `localizationProvider` を watch しているか
- `pubspec.yaml` に `flutter_localizations` が追加されているか
- 生成されたファイルが最新か確認（`flutter gen-l10n` を実行）

### 問題: 翻訳文字列が表示されない

**チェック項目:**
- `.arb` ファイルのキーが正しいか
- すべての言語ファイルに同じキーが存在するか
- JSONファイルが正しくフォーマットされているか

---

## パフォーマンス | Performance

- ローカライゼーション設定は `SharedPreferences` にキャッシュされます
- 言語変更時のリビルドは Riverpod により最適化されます
- 生成されたローカライゼーションファイルはツリーシェイキング対応です

---

## サポートされた言語の一覧 | Supported Languages

### Core Languages (2026年8月)

| 言語 | コード | フラグ | ステータス |
|------|-------|--------|-----------|
| 日本語 | ja | 🇯🇵 | ✅ 対応済み |
| 英語 | en | 🇺🇸 | ✅ 対応済み |
| 中国語（簡体字）| zh | 🇨🇳 | ✅ 対応済み |
| 韓国語 | ko | 🇰🇷 | ✅ 対応済み |

### Phase 1 Languages - Southeast Asia (2026年第4四半期)

| 言語 | コード | フラグ | ステータス |
|------|-------|--------|-----------|
| タイ語 | th | 🇹🇭 | ✅ 対応済み |
| ベトナム語 | vi | 🇻🇳 | ✅ 対応済み |
| インドネシア語 | id | 🇮🇩 | ✅ 対応済み |
| フィリピン語 | tl | 🇵🇭 | ✅ 対応済み |

### Phase 2 Languages - Europe (2027年予定)

| 言語 | コード | フラグ | ステータス |
|------|-------|--------|-----------|
| ドイツ語 | de | 🇩🇪 | 📋 計画中 |
| フランス語 | fr | 🇫🇷 | 📋 計画中 |

---

## 参考資料 | References

- [Flutter Localization Documentation](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Riverpod Documentation](https://riverpod.dev)

---

**最終更新**: 2026年8月30日 | **バージョン**: 1.1.0 (Phase 1言語対応追加)
