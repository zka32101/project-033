import 'package:flutter/material.dart';
import '../data/models/category_model.dart';

/// カテゴリ別修了バッジ(設計書Step5.5: ストリーク/修了バッジ・BtoBトーンの控えめな装飾)
class CategoryBadge extends StatelessWidget {
  final CategoryId categoryId;
  final bool earned;

  const CategoryBadge({super.key, required this.categoryId, required this.earned});

  static const _imagePaths = {
    CategoryId.infoMorals: 'assets/images/categories/category_info_morals.png',
    CategoryId.security: 'assets/images/categories/category_security.png',
    CategoryId.privacy: 'assets/images/categories/category_privacy.png',
    CategoryId.infoManagement: 'assets/images/categories/category_info_management.png',
    CategoryId.compliance: 'assets/images/categories/category_compliance.png',
    CategoryId.aiUsage: 'assets/images/categories/category_ai_usage.png',
    // ⑦⑧⑨は専用バッジ画像が未生成のため、_buildIconFallbackでアイコン表示にフォールバックする。
  };

  static const _iconFallbacks = {
    CategoryId.mentalHealth: Icons.favorite_outline,
    CategoryId.bcp: Icons.emergency_outlined,
    CategoryId.sustainability: Icons.eco_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final category = Category.byId(categoryId);
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = earned ? colorScheme.primary : colorScheme.outlineVariant;
    final imagePath = _imagePaths[categoryId];

    return Tooltip(
      message: category.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              // 未獲得のバッジは彩度を落として控えめに表示する(BtoBトーン: 過度な演出を避ける)
              child: imagePath == null
                  ? _buildIconFallback(colorScheme, textColor)
                  : earned
                      ? Image.asset(imagePath, fit: BoxFit.cover)
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.5, 0,
                          ]),
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: TextStyle(fontSize: 11, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildIconFallback(ColorScheme colorScheme, Color textColor) {
    return ColoredBox(
      color: earned ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      child: Icon(
        _iconFallbacks[categoryId] ?? Icons.category_outlined,
        color: textColor,
        size: 24,
      ),
    );
  }
}
