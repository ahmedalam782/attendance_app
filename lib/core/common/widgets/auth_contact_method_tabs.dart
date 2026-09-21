import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum AuthContactMethod { email, phone }

/// Segmented Email / Phone switch used on login & register.
class AuthContactMethodTabs extends StatelessWidget {
  const AuthContactMethodTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AuthContactMethod value;
  final ValueChanged<AuthContactMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: LocaleKeys.auth_tabs_email.tr(),
              selected: value == AuthContactMethod.email,
              onTap: () => onChanged(AuthContactMethod.email),
            ),
          ),
          Expanded(
            child: _TabChip(
              label: LocaleKeys.auth_tabs_phone.tr(),
              selected: value == AuthContactMethod.phone,
              onTap: () => onChanged(AuthContactMethod.phone),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.cardSurface : AppColors.transparent,
      borderRadius: BorderRadius.circular(11),
      elevation: selected ? 1 : 0,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: (selected ? 12.bold : 12.medium).copyWith(
              color: selected ? AppColors.primerColor : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }
}
