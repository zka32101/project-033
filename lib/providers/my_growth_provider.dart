import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import 'session_provider.dart';
import '../core/growth_analytics.dart';
import '../data/models/module_model.dart';

/// マイ成長画面: 全モジュールのcategoryIdマップを取得し、受験履歴と突き合わせてレーダースコアを算出
final myGrowthRadarProvider = FutureProvider<List<CategoryScore>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (!session.isSignedIn) return [];

  final contentService = ref.watch(contentServiceProvider);
  final quizService = ref.watch(quizServiceProvider);

  final allModules = await contentService.listModulesForIndustry(
    await contentService.getIndustry(session.company!.industryId) ??
        (throw StateError('industry not found: ${session.company!.industryId}')),
  );
  final moduleCategoryMap = <String, dynamic>{
    for (final Module m in allModules) m.id: m.categoryId,
  };

  final attempts = await quizService
      .watchAttempts(session.company!.id, session.employee!.id)
      .first;

  return GrowthAnalytics.computeRadarScores(
    attempts: attempts,
    moduleCategoryMap: moduleCategoryMap.cast(),
  );
});
