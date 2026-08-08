import '../models/industry_model.dart';
import '../models/category_model.dart';

/// 業種プロファイル種データ(設計書 Section3の優先度テーブルをそのままデータ化)。
/// Firebase Console設定後、bin/seed_firestore.dartでindustriesコレクションへ投入する。
const List<Industry> seedIndustries = [
  Industry(
    id: 'manufacturing',
    name: '製造業',
    highPriority: [CategoryId.security, CategoryId.infoManagement],
    midPriority: [CategoryId.compliance, CategoryId.privacy],
    lowPriority: [CategoryId.infoMorals, CategoryId.aiUsage],
  ),
  Industry(
    id: 'construction',
    name: '建設業',
    highPriority: [CategoryId.compliance],
    midPriority: [CategoryId.infoMorals, CategoryId.privacy],
    lowPriority: [CategoryId.security, CategoryId.infoManagement, CategoryId.aiUsage],
  ),
  Industry(
    id: 'healthcare',
    name: '医療・福祉',
    highPriority: [CategoryId.privacy, CategoryId.compliance],
    midPriority: [CategoryId.security],
    lowPriority: [CategoryId.infoMorals, CategoryId.infoManagement, CategoryId.aiUsage],
  ),
  Industry(
    id: 'it',
    name: 'IT/情報通信',
    highPriority: [CategoryId.security, CategoryId.aiUsage],
    midPriority: [CategoryId.infoManagement],
    lowPriority: [CategoryId.infoMorals, CategoryId.privacy, CategoryId.compliance],
  ),
  Industry(
    id: 'retail',
    name: '小売・飲食',
    highPriority: [CategoryId.infoMorals, CategoryId.privacy],
    midPriority: [CategoryId.compliance],
    lowPriority: [CategoryId.security, CategoryId.infoManagement, CategoryId.aiUsage],
  ),
  Industry(
    id: 'professional',
    name: '士業・専門サービス',
    highPriority: [CategoryId.privacy, CategoryId.compliance],
    midPriority: [CategoryId.security],
    lowPriority: [CategoryId.infoMorals, CategoryId.infoManagement, CategoryId.aiUsage],
  ),
  Industry(
    id: 'transport',
    name: '運輸業',
    highPriority: [CategoryId.compliance],
    midPriority: [CategoryId.infoMorals],
    lowPriority: [
      CategoryId.security,
      CategoryId.privacy,
      CategoryId.infoManagement,
      CategoryId.aiUsage,
    ],
  ),
  Industry(
    id: 'realestate',
    name: '不動産業',
    highPriority: [CategoryId.privacy, CategoryId.compliance],
    midPriority: [CategoryId.infoMorals],
    lowPriority: [CategoryId.security, CategoryId.infoManagement, CategoryId.aiUsage],
  ),
];
