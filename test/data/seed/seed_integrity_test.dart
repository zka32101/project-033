import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/seed/industries_seed.dart';
import 'package:safy/data/seed/modules_seed.dart';
import 'package:safy/data/seed/lessons_seed.dart';
import 'package:safy/data/seed/quiz_questions_seed.dart';
import 'package:safy/data/models/category_model.dart';

void main() {
  group('Seed data integrity (手書きデータの機械検証)', () {
    test('モジュールIDに重複がない', () {
      final ids = seedModules.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'モジュールID重複: $ids');
    });

    test('全モジュールのcategoryIdが6カテゴリのいずれかである', () {
      for (final module in seedModules) {
        expect(Category.all.map((c) => c.id), contains(module.categoryId),
            reason: '不正なcategoryId: ${module.id}');
      }
    });

    test('6カテゴリすべてに少なくとも1モジュールが存在する', () {
      final coveredCategories = seedModules.map((m) => m.categoryId).toSet();
      for (final category in Category.all) {
        expect(coveredCategories, contains(category.id),
            reason: 'モジュールが1つも無いカテゴリ: ${category.name}');
      }
    });

    test('全モジュールにレッスンが1件以上、キーとmoduleIdが一致する', () {
      for (final module in seedModules) {
        final lessons = seedLessonsByModule[module.id];
        expect(lessons, isNotNull, reason: 'レッスン未登録のモジュール: ${module.id}');
        expect(lessons!.isNotEmpty, isTrue, reason: 'レッスンが空のモジュール: ${module.id}');
        for (final lesson in lessons) {
          expect(lesson.moduleId, module.id,
              reason: 'lesson.moduleIdがマップキーと不一致: ${lesson.id}');
        }
      }
    });

    test('seedLessonsByModuleに存在しないモジュールIDのキーが無い(孤立データ無し)', () {
      final moduleIds = seedModules.map((m) => m.id).toSet();
      for (final key in seedLessonsByModule.keys) {
        expect(moduleIds, contains(key), reason: '存在しないモジュールを指すレッスンキー: $key');
      }
    });

    test('レッスンIDに重複がない', () {
      final allLessonIds =
          seedLessonsByModule.values.expand((lessons) => lessons.map((l) => l.id)).toList();
      expect(allLessonIds.toSet().length, allLessonIds.length,
          reason: 'レッスンID重複あり');
    });

    test('全モジュールにクイズ問題が3問以上、キーとmoduleIdが一致する', () {
      for (final module in seedModules) {
        final questions = seedQuizQuestionsByModule[module.id];
        expect(questions, isNotNull, reason: 'クイズ未登録のモジュール: ${module.id}');
        expect(questions!.length, greaterThanOrEqualTo(3),
            reason: 'クイズ問題が3問未満: ${module.id}');
        for (final q in questions) {
          expect(q.moduleId, module.id,
              reason: 'quizQuestion.moduleIdがマップキーと不一致: ${q.id}');
        }
      }
    });

    test('seedQuizQuestionsByModuleに存在しないモジュールIDのキーが無い', () {
      final moduleIds = seedModules.map((m) => m.id).toSet();
      for (final key in seedQuizQuestionsByModule.keys) {
        expect(moduleIds, contains(key), reason: '存在しないモジュールを指すクイズキー: $key');
      }
    });

    test('クイズ問題IDに重複がない', () {
      final allQuestionIds = seedQuizQuestionsByModule.values
          .expand((qs) => qs.map((q) => q.id))
          .toList();
      expect(allQuestionIds.toSet().length, allQuestionIds.length,
          reason: 'クイズ問題ID重複あり');
    });

    test('全クイズ問題のcorrectIndexが選択肢の範囲内にあり、選択肢に重複がない', () {
      for (final questions in seedQuizQuestionsByModule.values) {
        for (final q in questions) {
          expect(q.choices.length, greaterThanOrEqualTo(2),
              reason: '選択肢が2つ未満: ${q.id}');
          expect(q.correctIndex, greaterThanOrEqualTo(0), reason: '負のcorrectIndex: ${q.id}');
          expect(q.correctIndex, lessThan(q.choices.length),
              reason: 'correctIndexが選択肢数を超えている: ${q.id}');
          expect(q.choices.toSet().length, q.choices.length,
              reason: '選択肢に重複がある(誤って正解が複数になり得る): ${q.id}');
          expect(q.question.trim(), isNotEmpty, reason: '設問が空: ${q.id}');
          expect(q.explanation.trim(), isNotEmpty, reason: '解説が空: ${q.id}');
        }
      }
    });

    test('業種IDに重複がない', () {
      final ids = seedIndustries.map((i) => i.id).toList();
      expect(ids.toSet().length, ids.length, reason: '業種ID重複: $ids');
    });

    test('各業種の高/中/低優先度カテゴリが重複していない', () {
      for (final industry in seedIndustries) {
        final all = [
          ...industry.highPriority,
          ...industry.midPriority,
          ...industry.lowPriority,
        ];
        expect(all.toSet().length, all.length,
            reason: '優先度カテゴリが重複している業種: ${industry.id}');
      }
    });

    test('各業種で6カテゴリ全てが高/中/低いずれかに分類されている', () {
      for (final industry in seedIndustries) {
        final all = {
          ...industry.highPriority,
          ...industry.midPriority,
          ...industry.lowPriority,
        };
        expect(all.length, Category.all.length,
            reason: '未分類のカテゴリがある業種: ${industry.id}');
      }
    });
  });
}
