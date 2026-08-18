import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:safy/services/custom_content_service.dart';
import 'package:safy/services/content_service.dart';
import 'package:safy/services/subscription_service.dart';
import 'package:safy/data/models/category_model.dart';
import 'package:safy/data/models/generated_content_draft.dart';
import 'package:safy/data/models/subscription_model.dart';
import 'package:safy/data/models/module_model.dart';
import 'package:safy/data/models/lesson_model.dart';
import 'package:safy/data/models/quiz_question_model.dart';

/// プレミアムプラン(オリジナルコンテンツ機能)のFirestore側の一連の動作を検証する。
/// AI生成(Cloud Functions呼び出し)自体はfake_cloud_firestoreで代替できないため対象外とし、
/// 「AI生成結果のドラフトを保存 → 他社から見えない形で読み出せる → グローバルコンテンツと
/// 正しく合流する」という、保存以降のFirestore連携部分を検証する。
void main() {
  late FakeFirebaseFirestore db;
  late CustomContentService customContentService;
  late ContentService contentService;
  late SubscriptionService subscriptionService;

  const companyId = 'company-1';
  const otherCompanyId = 'company-2';
  const globalModuleId = 'm_ethics_sns';

  setUp(() async {
    db = FakeFirebaseFirestore();
    customContentService = CustomContentService(db);
    contentService = ContentService(db);
    subscriptionService = SubscriptionService(db);

    // グローバルモジュール1件+レッスン1件+クイズ1問を用意(実シードの縮小版)。
    await db.collection('modules').doc(globalModuleId).set(const Module(
          id: globalModuleId,
          categoryId: CategoryId.infoMorals,
          title: 'SNS利用と情報発信のリスク',
          description: '既存のグローバルモジュール',
          passThresholdDefault: 80,
          isFreeTrial: true,
          sortOrder: 1,
        ).toMap());
    await db
        .collection('modules/$globalModuleId/lessons')
        .doc('l1')
        .set(const Lesson(
          id: 'l1',
          moduleId: globalModuleId,
          title: '既存レッスン',
          body: '既存レッスン本文',
          imageUrls: [],
          sortOrder: 1,
        ).toMap());
    await db
        .collection('modules/$globalModuleId/quizQuestions')
        .doc('q1')
        .set(const QuizQuestion(
          id: 'q1',
          moduleId: globalModuleId,
          question: '既存の問題',
          choices: ['a', 'b', 'c', 'd'],
          correctIndex: 0,
          explanation: '既存の解説',
        ).toMap());
  });

  group('SubscriptionService: premiumTierの永続化', () {
    test('upsertPremiumTierで設定した段階が保存・取得できる', () async {
      await subscriptionService.upsertPremiumTier(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyId,
        premiumTier: PremiumTier.moduleCreation,
        headcount: 10,
      );

      final subscription = await subscriptionService.getActiveSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyId,
      );

      expect(subscription, isNotNull);
      expect(subscription!.premiumTier, PremiumTier.moduleCreation);
      expect(subscription.canCreateOriginalModules, isTrue);
    });

    test('upsertSubscription(モジュール購入)はpremiumTierを維持する(意図せずリセットしない)', () async {
      await subscriptionService.upsertPremiumTier(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyId,
        premiumTier: PremiumTier.moduleExtension,
        headcount: 10,
      );

      // 通常のモジュール追加購入(paywall_screen.dartの_purchaseと同じ呼び出し)
      await subscriptionService.upsertSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyId,
        subscribedModuleIds: ['m_security_basics'],
        fullSet: false,
        headcount: 10,
      );

      final subscription = await subscriptionService.getActiveSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyId,
      );

      expect(subscription!.premiumTier, PremiumTier.moduleExtension,
          reason: 'モジュール購入でpremiumTierがnoneに巻き戻ってはいけない');
      expect(subscription.subscribedModuleIds, ['m_security_basics']);
    });
  });

  group('CustomContentService: 新規オリジナルモジュール作成', () {
    test('AI生成ドラフトを保存し、レッスン・クイズを合わせて読み出せる', () async {
      final draft = GeneratedContentDraft(
        moduleTitle: '熱中症予防と応急対応',
        moduleDescription: '建設現場での熱中症予防に関するオリジナル研修',
        lessons: [
          DraftLesson(title: '導入', body: '熱中症の基礎知識'),
          DraftLesson(title: '応急対応', body: '発症時の対応手順'),
        ],
        quizQuestions: [
          DraftQuizQuestion(
            question: '熱中症の初期症状はどれ?',
            choices: ['めまい', '骨折', '虫歯', '花粉症'],
            correctIndex: 0,
            explanation: 'めまいや立ちくらみは熱中症の初期症状の代表例です。',
          ),
        ],
      );

      final module = await customContentService.saveNewModule(
        companyId: companyId,
        categoryId: CategoryId.security,
        theme: '熱中症予防',
        createdByEmployeeId: 'admin-1',
        draft: draft,
      );

      expect(module.title, '熱中症予防と応急対応');
      expect(module.companyId, companyId);

      final lessons =
          await customContentService.listCustomModuleLessons(companyId, module.id);
      expect(lessons.length, 2);
      expect(lessons.map((l) => l.title), containsAll(['導入', '応急対応']));

      final questions = await customContentService
          .listCustomModuleQuizQuestions(companyId, module.id);
      expect(questions.length, 1);
      expect(questions.single.correctIndex, 0);

      final modules = await customContentService.listCustomModules(companyId);
      expect(modules.single.id, module.id);
    });

    test('A社が作成したオリジナルモジュールはB社からは見えない(マルチテナント分離)', () async {
      final draft = GeneratedContentDraft(
        moduleTitle: 'A社専用モジュール',
        moduleDescription: 'A社限定',
        lessons: [DraftLesson(title: 'L', body: 'B')],
        quizQuestions: [
          DraftQuizQuestion(
            question: 'Q',
            choices: ['1', '2', '3', '4'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
      );

      await customContentService.saveNewModule(
        companyId: companyId,
        categoryId: CategoryId.security,
        theme: 'テスト',
        createdByEmployeeId: 'admin-1',
        draft: draft,
      );

      final otherCompanyModules =
          await customContentService.listCustomModules(otherCompanyId);
      expect(otherCompanyModules, isEmpty);
    });
  });

  group('CustomContentService + ContentService: 既存モジュールへの追加', () {
    test('追加したレッスン・クイズが既存モジュールの内容の後ろに連結される', () async {
      final draft = GeneratedContentDraft(
        lessons: [DraftLesson(title: '追加レッスン', body: '追加本文')],
        quizQuestions: [
          DraftQuizQuestion(
            question: '追加の問題',
            choices: ['a', 'b', 'c', 'd'],
            correctIndex: 1,
            explanation: '追加の解説',
          ),
        ],
      );

      await customContentService.saveModuleExtension(
        companyId: companyId,
        targetModuleId: globalModuleId,
        theme: '補足テーマ',
        draft: draft,
      );

      final lessons =
          await contentService.listLessonsForCompany(globalModuleId, companyId);
      expect(lessons.length, 2);
      expect(lessons.first.title, '既存レッスン', reason: '既存コンテンツが先頭に来ること');
      expect(lessons.last.title, '追加レッスン', reason: '追加コンテンツが末尾に来ること');

      final questions =
          await contentService.listQuizQuestionsForCompany(globalModuleId, companyId);
      expect(questions.length, 2);
      expect(questions.first.question, '既存の問題');
      expect(questions.last.question, '追加の問題');

      final extendedIds = await customContentService.listExtendedModuleIds(companyId);
      expect(extendedIds, contains(globalModuleId));
    });

    test('追加していない会社には既存コンテンツのみが返る', () async {
      final lessons =
          await contentService.listLessonsForCompany(globalModuleId, otherCompanyId);
      expect(lessons.length, 1);
      expect(lessons.single.title, '既存レッスン');
    });
  });
}
