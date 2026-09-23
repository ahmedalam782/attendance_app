import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class InstructorInviteItem {
  const InstructorInviteItem({
    required this.code,
    required this.isUsed,
    this.createdAt,
    this.redeemedAt,
    this.usedBy,
    this.usedByName,
    this.usedByEmail,
  });

  final String code;
  final bool isUsed;
  final DateTime? createdAt;
  final DateTime? redeemedAt;
  final String? usedBy;
  final String? usedByName;
  final String? usedByEmail;
}

class CreateInstructorInviteSheet extends StatefulWidget {
  const CreateInstructorInviteSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppSheet<void>(
      context,
      builder: (_) => const CreateInstructorInviteSheet(),
    );
  }

  @override
  State<CreateInstructorInviteSheet> createState() =>
      _CreateInstructorInviteSheetState();
}

class _CreateInstructorInviteSheetState
    extends State<CreateInstructorInviteSheet> {
  int _selectedTabIndex = 0; // 0: Code & QR, 1: History
  String? _selectedCode;
  List<InstructorInviteItem> _invites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingOrGenerate();
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final buffer = StringBuffer('INST-');
    for (var i = 0; i < 5; i++) {
      buffer.write(chars[rnd.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  Future<void> _loadExistingOrGenerate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('instructorInvites')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      final missingUids = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final used = data['used'] == true;
        final usedBy = data['usedBy'] as String?;
        final usedByName = data['usedByName'] as String?;
        if (used && usedBy != null && (usedByName == null || usedByName.isEmpty)) {
          missingUids.add(usedBy);
        }
      }

      final Map<String, Map<String, String?>> userDetails = {};
      if (missingUids.isNotEmpty) {
        await Future.wait(missingUids.map((uid) async {
          try {
            final uDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            if (uDoc.exists) {
              final uData = uDoc.data();
              userDetails[uid] = {
                'name': (uData?['name'] ?? uData?['displayName']) as String?,
                'email': uData?['email'] as String?,
              };
            }
          } catch (_) {}
        }));
      }

      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        final usedBy = data['usedBy'] as String?;
        final usedByName = (data['usedByName'] as String?) ?? userDetails[usedBy]?['name'];
        final usedByEmail = (data['usedByEmail'] as String?) ?? userDetails[usedBy]?['email'];
        return InstructorInviteItem(
          code: doc.id,
          isUsed: data['used'] == true,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
          redeemedAt: (data['redeemedAt'] as Timestamp?)?.toDate(),
          usedBy: usedBy,
          usedByName: usedByName,
          usedByEmail: usedByEmail,
        );
      }).toList();

      // Find if there is an existing unused active code
      final existingUnused = items.cast<InstructorInviteItem?>().firstWhere(
            (it) => it != null && !it.isUsed,
            orElse: () => null,
          );

      if (existingUnused != null) {
        if (mounted) {
          setState(() {
            _invites = items;
            _selectedCode = existingUnused.code;
            _isLoading = false;
          });
        }
      } else {
        // No unused code exists, generate one
        await _generateAndSaveInvite(existingItems: items);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _generateAndSaveInvite({List<InstructorInviteItem>? existingItems}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final code = _randomCode();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'admin';

    try {
      await FirebaseFirestore.instance
          .collection('instructorInvites')
          .doc(code)
          .set({
        'used': false,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newItem = InstructorInviteItem(
        code: code,
        isUsed: false,
        createdAt: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _selectedCode = code;
          _selectedTabIndex = 0; // Switch to Code & QR tab
          _invites = [newItem, ...(existingItems ?? _invites)];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _copyCode([String? codeToCopy]) {
    final code = codeToCopy ?? _selectedCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    CustomToast(
      context: context,
      header: LocaleKeys.settings_extra_admin_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  void _shareCode([String? codeToShare]) {
    final code = codeToShare ?? _selectedCode;
    if (code == null) return;
    final isArabic = context.locale.languageCode == 'ar';
    final message = isArabic
        ? 'رمز دعوة الانضمام كمدرب في تطبيق Elevate:\n$code\n\nقم بفتح شاشة الإعدادات > تفعيل حساب مدرب، وأدخل هذا الرمز لتفعيل صلاحياتك.'
        : 'Instructor invite code for Elevate Attendance:\n$code\n\nOpen Settings > Redeem Instructor Code in the app to activate your instructor account.';
    SharePlus.instance.share(ShareParams(text: message));
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy/MM/dd - hh:mm a').format(dt);
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              title: LocaleKeys.settings_extra_invite_tab_code.tr(),
              icon: Icons.qr_code_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 1,
              title: LocaleKeys.settings_extra_invite_tab_history.tr(),
              icon: Icons.history_rounded,
              badgeCount: _invites.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required IconData icon,
    int? badgeCount,
  }) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.originalWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primerColor : AppColors.slate500,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: (isSelected ? 12.bold : 12.medium).copyWith(
                color: isSelected ? AppColors.slate900 : AppColors.slate600,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primerColor.withValues(alpha: 0.1)
                      : AppColors.slate200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: 10.bold.copyWith(
                    color: isSelected
                        ? AppColors.primerColor
                        : AppColors.slate600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCodeView() {
    final currentItem = _invites.cast<InstructorInviteItem?>().firstWhere(
          (it) => it?.code == _selectedCode,
          orElse: () => null,
        );
    final isCurrentUsed = currentItem?.isUsed ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isCurrentUsed)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.present.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.present.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.present,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LocaleKeys.settings_extra_invite_active_hint.tr(),
                    style: 11.medium.copyWith(color: AppColors.present),
                  ),
                ),
              ],
            ),
          ),

        // QR Code Card
        Center(
          child: QrCard(
            token: 'attendance:instructor:$_selectedCode',
            title: _selectedCode!,
            size: 160,
            footerText:
                LocaleKeys.settings_extra_admin_qr_display_instruction.tr(),
          ),
        ),
        const SizedBox(height: 12),

        // Code Box Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrentUsed ? AppColors.slate100 : AppColors.slate50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUsed ? AppColors.slate300 : AppColors.slate200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentUsed
                      ? AppColors.slate200
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCurrentUsed
                      ? Icons.lock_clock_rounded
                      : Icons.vpn_key_rounded,
                  color:
                      isCurrentUsed ? AppColors.slate500 : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _selectedCode!,
                      style: 18.bold.copyWith(
                        color: isCurrentUsed
                            ? AppColors.slate600
                            : AppColors.slate900,
                        letterSpacing: 1.5,
                        decoration:
                            isCurrentUsed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      isCurrentUsed
                          ? LocaleKeys.settings_extra_invite_status_used.tr()
                          : LocaleKeys.settings_extra_invite_active_ready.tr(),
                      style: 11.medium.copyWith(
                        color: isCurrentUsed
                            ? AppColors.absent
                            : AppColors.present,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: LocaleKeys.settings_extra_admin_copy_code.tr(),
                icon: const Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _copyCode(_selectedCode),
              ),
              IconButton(
                tooltip: LocaleKeys.settings_extra_admin_share_code.tr(),
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _shareCode(_selectedCode),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: CustomButton(
                title: LocaleKeys.settings_extra_admin_share_code.tr(),
                isFilled: true,
                backGroundColor: AppColors.primary,
                titleStyle: 13.bold.copyWith(color: Colors.white),
                prefixIcon: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                onTap: () => _shareCode(_selectedCode),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
                isFilled: true,
                isGradient: false,
                backGroundColor: AppColors.slate100,
                borderColor: AppColors.slate300,
                titleStyle: 13.bold.copyWith(color: AppColors.slate800),
                prefixIcon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.slate800,
                  size: 16,
                ),
                onTap: () => _generateAndSaveInvite(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    if (_invites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_toggle_off_rounded,
                size: 40,
                color: AppColors.slate300,
              ),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.settings_extra_no_invites_yet.tr(),
                style: 13.medium.copyWith(color: AppColors.slate400),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 330),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _invites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _invites[index];
              final isSelected = item.code == _selectedCode;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCode = item.code;
                    _selectedTabIndex = 0; // Switch to QR tab
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primerColor.withValues(alpha: 0.05)
                        : AppColors.slate50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primerColor
                          : AppColors.slate200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.isUsed
                              ? AppColors.present.withValues(alpha: 0.12)
                              : AppColors.absent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.isUsed
                              ? Icons.check_circle_rounded
                              : Icons.qr_code_2_rounded,
                          size: 18,
                          color: item.isUsed
                              ? AppColors.present
                              : AppColors.absent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.code,
                              style: 14.bold.copyWith(
                                color: item.isUsed
                                    ? AppColors.slate500
                                    : AppColors.slate900,
                                letterSpacing: 0.8,
                                decoration: item.isUsed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (item.createdAt != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(item.createdAt),
                                style: 10.regular.copyWith(
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                            if (item.isUsed &&
                                (item.usedByName != null || item.usedByEmail != null)) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.usedByName ?? item.usedByEmail!,
                                style: 10.medium.copyWith(
                                  color: AppColors.slate700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item.isUsed
                              ? AppColors.present.withValues(alpha: 0.12)
                              : AppColors.absent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isUsed
                              ? LocaleKeys.settings_extra_invite_status_used.tr()
                              : LocaleKeys.settings_extra_invite_status_active.tr(),
                          style: 10.bold.copyWith(
                            color: item.isUsed
                                ? AppColors.present
                                : AppColors.absent,
                          ),
                        ),
                      ),
                      if (!item.isUsed) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _copyCode(item.code),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _shareCode(item.code),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        CustomButton(
          title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
          isFilled: true,
          isGradient: false,
          backGroundColor: AppColors.slate100,
          borderColor: AppColors.slate300,
          titleStyle: 13.bold.copyWith(color: AppColors.slate800),
          prefixIcon: const Icon(
            Icons.add_circle_outline_rounded,
            color: AppColors.slate800,
            size: 16,
          ),
          onTap: () => _generateAndSaveInvite(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPadding(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: LocaleKeys.settings_extra_admin_create_invite_title.tr(),
              subtitle:
                  LocaleKeys.settings_extra_admin_create_invite_subtitle.tr(),
            ),
            const SizedBox(height: 14),

            // Tabs Selector: Code & QR vs History
            _buildTabSelector(),
            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: 13.regular.copyWith(color: AppColors.absent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
                      onTap: () => _generateAndSaveInvite(),
                    ),
                  ],
                ),
              )
            else if (_selectedTabIndex == 0 && _selectedCode != null)
              _buildCodeView()
            else if (_selectedTabIndex == 1)
              _buildHistoryView(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
