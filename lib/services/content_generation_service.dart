import 'package:cloud_functions/cloud_functions.dart';
import '../data/models/generated_content_draft.dart';

/// プレミアムプラン向けオリジナルコンテンツのAI生成(Cloud Functions `generateOriginalContent`経由)。
/// 生成結果は保存されない。管理者が画面上で確認・編集した後、
/// CustomContentServiceで明示的に保存するまでFirestoreには一切書き込まれない。
class ContentGenerationService {
  final FirebaseFunctions _functions;
  ContentGenerationService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  /// 既存モジュールへ追加するレッスン+クイズを生成する(要moduleExtension以上のプラン)。
  Future<GeneratedContentDraft> generateExtension({
    required String companyId,
    required String targetModuleId,
    required String theme,
  }) async {
    final result = await _functions.httpsCallable('generateOriginalContent').call({
      'companyId': companyId,
      'mode': 'extend',
      'theme': theme,
      'targetModuleId': targetModuleId,
    });
    return GeneratedContentDraft.fromMap(Map<String, dynamic>.from(result.data as Map));
  }

  /// 新規オリジナルモジュール一式(タイトル・説明・レッスン+クイズ)を生成する(要moduleCreationプラン)。
  Future<GeneratedContentDraft> generateNewModule({
    required String companyId,
    required String categoryId,
    required String theme,
  }) async {
    final result = await _functions.httpsCallable('generateOriginalContent').call({
      'companyId': companyId,
      'mode': 'create',
      'theme': theme,
      'categoryId': categoryId,
    });
    return GeneratedContentDraft.fromMap(Map<String, dynamic>.from(result.data as Map));
  }
}
