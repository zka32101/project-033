// Firestoreへ種データ(業種/モジュール/レッスン/クイズ問題)を投入するスクリプト。
//
// 前提条件(Firebase Console設定完了後に実行すること・現時点ではfirebase_options.dart未生成のため未使用):
//   1. [flutter-firebase-setup]スキルの手順でFirebaseプロジェクトを作成し、
//      `flutterfire configure` で lib/firebase_options.dart を生成すること
//   2. 生成後、下記のimportコメントを解除し、Firebase.initializeApp(options: ...)に
//      DefaultFirebaseOptions.currentPlatform を渡すこと
//   3. `flutter pub get` 済みであること
//
// 実行方法:
//   dart run bin/seed_firestore.dart
//
// 冪等性: 同じIDのドキュメントは上書き(set)されるため、複数回実行しても重複は発生しない。

// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:safy/data/seed/industries_seed.dart';
import 'package:safy/data/seed/modules_seed.dart';
import 'package:safy/data/seed/lessons_seed.dart';
import 'package:safy/data/seed/quiz_questions_seed.dart';
// import 'package:safy/firebase_options.dart'; // flutterfire configure実行後にコメント解除

Future<void> main() async {
  // firebase_options.dart生成後は以下に差し替えること:
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  final db = FirebaseFirestore.instance;

  print('--- industries (${seedIndustries.length}件) ---');
  for (final industry in seedIndustries) {
    await db.collection('industries').doc(industry.id).set(industry.toMap());
    print('  ✓ ${industry.id} (${industry.name})');
  }

  print('--- modules (${seedModules.length}件) ---');
  for (final module in seedModules) {
    await db.collection('modules').doc(module.id).set(module.toMap());
    print('  ✓ ${module.id} (${module.title})');

    final lessons = seedLessonsByModule[module.id] ?? const [];
    for (final lesson in lessons) {
      await db
          .collection('modules/${module.id}/lessons')
          .doc(lesson.id)
          .set(lesson.toMap());
    }
    print('    - lessons: ${lessons.length}件');

    final questions = seedQuizQuestionsByModule[module.id] ?? const [];
    for (final question in questions) {
      await db
          .collection('modules/${module.id}/quizQuestions')
          .doc(question.id)
          .set(question.toMap());
    }
    print('    - quizQuestions: ${questions.length}件');
  }

  print('--- 投入完了 ---');
}
