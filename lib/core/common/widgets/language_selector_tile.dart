import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    final isArabic = currentLocale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.settings_extra_language_title.tr(),
                  style: 14.bold.copyWith(color: AppColors.slate900),
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic
                      ? LocaleKeys.settings_extra_language_ar.tr()
                      : LocaleKeys.settings_extra_language_en.tr(),
                  style: 12.medium.copyWith(color: AppColors.slate500),
                ),
              ],
            ),
          ),
          // Language Switch buttons
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOption(
                  context,
                  title: 'English',
                  isSelected: !isArabic,
                  onTap: () => context.setLocale(const Locale('en', 'US')),
                ),
                _buildOption(
                  context,
                  title: 'العربية',
                  isSelected: isArabic,
                  onTap: () => context.setLocale(const Locale('ar', 'EG')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: isSelected
              ? 11.bold.copyWith(color: AppColors.primary)
              : 11.medium.copyWith(color: AppColors.slate500),
        ),
      ),
    );
  }
}
