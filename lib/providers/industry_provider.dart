import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../data/models/industry_model.dart';
import '../data/models/module_model.dart';

final industryListProvider = FutureProvider<List<Industry>>((ref) async {
  return ref.watch(contentServiceProvider).listIndustries();
});

/// 業種選択後、優先度順に並んだモジュール一覧を返す（Aha Moment動線: ホーム画面の優先モジュール表示）
final modulesForIndustryProvider =
    FutureProvider.family<List<Module>, Industry>((ref, industry) async {
  return ref.watch(contentServiceProvider).listModulesForIndustry(industry);
});
