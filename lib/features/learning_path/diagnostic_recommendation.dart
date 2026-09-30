/// レベル診断結果・受講履歴をもとにしたモジュール推薦ロジック。
///
/// [level_diagnostic_screen.dart] と [learning_path_screen.dart] の
/// 両方から参照される共通ロジック（Firestore/Riverpodに依存しない純粋な関数群）。

/// 診断の質問カテゴリと、モジュール推薦時のキーワードマッチングに使うキーワード群。
class DiagnosticCategory {
  final String label;
  final List<String> keywords;

  /// Safyの分野ID(CategoryId.name)。モジュールの `categoryId` と一致するものを優先して推薦する。
  final String categoryId;

  const DiagnosticCategory(this.label, this.keywords, {this.categoryId = ''});
}

/// 質問インデックス(0-8) → 分野定義(Safyの9分野)。
/// `level_diagnostic_screen.dart` の `diagnosticQuestions` の並び順と対応している。
const List<DiagnosticCategory> kDiagnosticQuestionCategories = [
  DiagnosticCategory('情報モラル', ['SNS', '情報モラル', 'ハラスメント', '著作権', 'マナー', '配慮', 'カスタマー'], categoryId: 'infoMorals'),
  DiagnosticCategory('セキュリティ', ['パスワード', 'フィッシング', 'ランサム', 'デバイス', 'セキュリティ', 'サイバー'], categoryId: 'security'),
  DiagnosticCategory('個人情報保護', ['個人情報', 'マイナンバー', '越境', '安全管理'], categoryId: 'privacy'),
  DiagnosticCategory('情報マネジメント', ['文書管理', 'インシデント', 'アクセス権限', 'BYOD', '複合機', 'ログ'], categoryId: 'infoManagement'),
  DiagnosticCategory('コンプライアンス', ['コンプライアンス', '下請', '取適', '贈収賄', 'インサイダー', '反社', '通報', '労務'], categoryId: 'compliance'),
  DiagnosticCategory('AI活用', ['AI', '生成AI', 'ディープフェイク', 'チャットボット'], categoryId: 'aiUsage'),
  DiagnosticCategory('メンタルヘルス・健康経営', ['メンタル', 'ストレス', '健康', '休職', '復職', '過重労働', '熱中症', '安全衛生'], categoryId: 'mentalHealth'),
  DiagnosticCategory('BCP・危機管理/防災', ['BCP', '災害', '安否', '感染症', 'サプライチェーン', '風評'], categoryId: 'bcp'),
  DiagnosticCategory('環境・サステナビリティ', ['SDGs', '省エネ', '脱炭素', '環境', 'グリーン', 'CSR'], categoryId: 'sustainability'),
];

/// 弱点分野ごとの推薦理由テンプレート。
const Map<String, String> kWeakCategoryReasons = {
  '情報モラル': '情報モラル(SNS・ハラスメント・著作権など)の基礎を補うモジュールをお勧めします',
  'セキュリティ': 'セキュリティ(パスワード・不審メール・端末管理など)の基礎を補うモジュールをお勧めします',
  '個人情報保護': '個人情報の取り扱いルールを補うモジュールをお勧めします',
  '情報マネジメント': '文書・アクセス権限・インシデント対応など、情報の管理を補うモジュールをお勧めします',
  'コンプライアンス': '法令遵守・取引・労務の基本を補うモジュールをお勧めします',
  'AI活用': '生成AIを安全に使うためのモジュールをお勧めします',
  'メンタルヘルス・健康経営': '心身の健康管理・ラインケアを補うモジュールをお勧めします',
  'BCP・危機管理/防災': '災害・緊急時の事業継続への備えを補うモジュールをお勧めします',
  '環境・サステナビリティ': '環境配慮・SDGsへの対応を補うモジュールをお勧めします',
};

/// 回答（質問インデックス→選択肢インデックス 0-3）から弱点分野を推定する。
/// 選択肢インデックスが低い(0 or 1)ほど経験・スキルが浅いと判断する。
List<String> determineWeakCategories(Map<int, int> answers) {
  final weak = <String>[];
  for (var i = 0; i < kDiagnosticQuestionCategories.length; i++) {
    final answer = answers[i];
    if (answer != null && answer <= 1) {
      weak.add(kDiagnosticQuestionCategories[i].label);
    }
  }
  return weak;
}

/// Firestoreに保存された診断結果の `answers` フィールド
/// （キーが文字列の Map になっている場合がある）を `Map<int, int>` に正規化する。
Map<int, int> normalizeDiagnosticAnswers(dynamic rawAnswers) {
  final result = <int, int>{};
  if (rawAnswers is Map) {
    rawAnswers.forEach((key, value) {
      final index = int.tryParse(key.toString());
      final answer =
          value is num ? value.toInt() : int.tryParse(value.toString());
      if (index != null && answer != null) {
        result[index] = answer;
      }
    });
  }
  return result;
}

/// 特定モジュールに対する、社員の受講履歴の要約。
class ModuleProgressSummary {
  final bool isPassed;
  final int maxScore;
  final int lessonsCompleted;

  const ModuleProgressSummary({
    required this.isPassed,
    required this.maxScore,
    required this.lessonsCompleted,
  });
}

/// 推薦モジュールとその推薦理由。
class RecommendedModule {
  final Map<String, dynamic> module;
  final String reason;

  const RecommendedModule({required this.module, required this.reason});
}

class _ScoredModule {
  final Map<String, dynamic> module;
  final int score;
  final String reason;

  const _ScoredModule({
    required this.module,
    required this.score,
    required this.reason,
  });
}

/// 診断結果（弱点分野）と受講履歴（進捗が低い/未受講）をもとに、
/// [modules] の中から優先的に受講すべきモジュールを選定する。
///
/// - 弱点分野のキーワードにマッチするモジュールを優先
/// - 未受講・進捗が低い（合格していない）モジュールを優先
/// - 既に合格済みのモジュールは推薦対象から除外
List<RecommendedModule> buildModuleRecommendations({
  required List<Map<String, dynamic>> modules,
  required List<String> weakCategories,
  required Map<String, ModuleProgressSummary> progressByModuleId,
  int limit = 4,
}) {
  final scored = <_ScoredModule>[];

  for (final module in modules) {
    final id = module['id'] as String? ?? '';
    final progress = progressByModuleId[id];

    // 合格済みのモジュールはおすすめ対象から除外
    if (progress != null && progress.isPassed) {
      continue;
    }

    final title = module['title'] as String? ?? '';
    final category = module['category'] as String? ?? '';
    final description = module['description'] as String? ?? '';
    final searchText = '$title $category $description';

    final matchedCategories = weakCategories.where((weak) {
      final def = kDiagnosticQuestionCategories.firstWhere(
        (c) => c.label == weak,
        orElse: () => const DiagnosticCategory('', []),
      );
      final moduleCategoryId = module['categoryId'] as String? ?? '';
      if (def.categoryId.isNotEmpty && moduleCategoryId == def.categoryId) {
        return true;
      }
      return def.keywords.any((keyword) => searchText.contains(keyword));
    }).toList();

    var score = 0;
    final reasons = <String>[];

    if (matchedCategories.isNotEmpty) {
      score += 2;
      final reason = kWeakCategoryReasons[matchedCategories.first];
      if (reason != null) {
        reasons.add(reason);
      }
    }

    if (progress == null) {
      score += 1;
      reasons.add('まだ受講していないモジュールです');
    } else if (!progress.isPassed) {
      score += 1;
      reasons.add('受講途中のため、修了を目指しましょう（現在のスコア: ${progress.maxScore}点）');
    }

    if (score == 0) {
      continue;
    }

    scored.add(_ScoredModule(
      module: module,
      score: score,
      reason: reasons.join('。'),
    ));
  }

  scored.sort((a, b) => b.score.compareTo(a.score));

  return scored
      .take(limit)
      .map((s) => RecommendedModule(module: s.module, reason: s.reason))
      .toList();
}
