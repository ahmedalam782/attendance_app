import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'create_instructor_invite_sheet.dart';

/// Public body widget for [InstructorInvitesHistoryPage] following Al Faris presentation architecture.
class InstructorInvitesHistoryBody extends StatefulWidget {
  const InstructorInvitesHistoryBody({super.key});

  @override
  State<InstructorInvitesHistoryBody> createState() =>
      _InstructorInvitesHistoryBodyState();
}

class _InstructorInvitesHistoryBodyState
    extends State<InstructorInvitesHistoryBody> {
  List<InstructorInviteItem> _invites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  InstructorInviteItem? get _activeUnusedInvite =>
      _invites.cast<InstructorInviteItem?>().firstWhere(
            (it) => it != null && !it.isUsed,
            orElse: () => null,
          );

  bool get _hasActiveUnused => _activeUnusedInvite != null;

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final buffer = StringBuffer('INST-');
    for (var i = 0; i < 5; i++) {
      buffer.write(chars[rnd.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  Future<void> _loadInvites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('instructorInvites')
          .orderBy('createdAt', descending: true)
          .limit(50)
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

      if (mounted) {
        setState(() {
          _invites = items;
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

  Future<void> _generateAndSaveInvite() async {
    final activeUnused = _activeUnusedInvite;
    final isArabic = context.locale.languageCode == 'ar';

    if (activeUnused != null) {
      CustomToast(
        context: context,
        header: isArabic
            ? 'يوجد كود نشط بالفعل لم يُستخدم بعد (${activeUnused.code})'
            : 'An active code already exists (${activeUnused.code})',
        type: ToastificationType.warning,
      ).showToast();
      return;
    }

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
          _invites = [newItem, ..._invites];
          _isLoading = false;
        });

        CustomToast(
          context: context,
          header: isArabic
              ? 'تم إنشاء كود الدعوة بنجاح'
              : 'Invite code created successfully',
          type: ToastificationType.success,
        ).showToast();

        // Navigate to the code page to view/share the new code
        context.router.push(InstructorInviteCodeRoute(initialCode: code));
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

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    CustomToast(
      context: context,
      header: LocaleKeys.settings_extra_admin_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  void _shareCode(String code) {
    final isArabic = context.locale.languageCode == 'ar';
    final message = isArabic
        ? 'رمز دعوة الانضمام كمدرب في تطبيق Elevate:\n$code\n\nقم بفتح شاشة الإعدادات > تفعيل حساب مدرب، وأدخل هذا الرمز لتفعيل صلاحياتك.'
        : 'Instructor invite code for Elevate Attendance:\n$code\n\nOpen Settings > Redeem Instructor Code in the app to activate your instructor account.';
    SharePlus.instance.share(ShareParams(text: message));
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy/MM/dd · hh:mm a').format(dt);
  }

  Widget _buildTopBar() {
    final isArabic = context.locale.languageCode == 'ar';

    return Row(
      children: [
        IconButton(
          onPressed: () => context.router.pop(),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.slate100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.slate800,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.settings_extra_invite_history_title.tr(),
                style: 16.bold.copyWith(color: AppColors.slate900),
              ),
              const SizedBox(height: 2),
              Text(
                isArabic
                    ? 'سجل أكواد الدعوة وحالة كل كود'
                    : 'Log of generated invite codes and their status',
                style: 11.medium.copyWith(color: AppColors.slate500),
              ),
            ],
          ),
        ),
        if (!_hasActiveUnused)
          IconButton(
            tooltip: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
            onPressed: () => _generateAndSaveInvite(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(
              Icons.add_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryItemCard(InstructorInviteItem item) {
    final isArabic = context.locale.languageCode == 'ar';

    return InkWell(
      onTap: () {
        context.router.push(InstructorInviteCodeRoute(initialCode: item.code));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isUsed ? AppColors.slate200 : AppColors.primary.withValues(alpha: 0.3),
            width: item.isUsed ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate900.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: item.isUsed
                        ? AppColors.slate100
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isUsed
                        ? Icons.check_circle_outline_rounded
                        : Icons.vpn_key_rounded,
                    size: 15,
                    color: item.isUsed ? AppColors.slate500 : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.code,
                    style: 14.bold.copyWith(
                      color: item.isUsed ? AppColors.slate600 : AppColors.slate900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (item.isUsed ? AppColors.present : AppColors.absent)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isUsed
                        ? LocaleKeys.settings_extra_invite_status_used.tr()
                        : LocaleKeys.settings_extra_invite_active_ready.tr(),
                    style: 10.bold.copyWith(
                      color: item.isUsed ? AppColors.present : AppColors.absent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.createdAt),
                  style: 11.regular.copyWith(color: AppColors.slate400),
                ),
                const Spacer(),
                if (!item.isUsed) ...[
                  InkWell(
                    onTap: () => _copyCode(item.code),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            isArabic ? 'نسخ' : 'Copy',
                            style: 11.bold.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _shareCode(item.code),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Icon(Icons.share_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            isArabic ? 'مشاركة' : 'Share',
                            style: 11.bold.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (item.isUsed) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: AppColors.slate500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.usedByName?.isNotEmpty == true
                            ? item.usedByName!
                            : (item.usedByEmail ?? (isArabic ? 'مدرب مُفعَّل' : 'Active Instructor')),
                        style: 11.medium.copyWith(color: AppColors.slate700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.redeemedAt != null)
                      Text(
                        _formatDate(item.redeemedAt),
                        style: 10.regular.copyWith(color: AppColors.slate400),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 44,
              color: AppColors.slate300,
            ),
            const SizedBox(height: 10),
            Text(
              LocaleKeys.settings_extra_no_invites_yet.tr(),
              style: 14.medium.copyWith(color: AppColors.slate500),
            ),
            const SizedBox(height: 18),
            CustomButton(
              title: isArabic ? 'إنشاء كود جديد' : 'Generate New Code',
              onTap: () => _generateAndSaveInvite(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Stack(
      children: [
        const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: 13.regular.copyWith(color: AppColors.absent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          title: isArabic ? 'إعادة المحاولة' : 'Retry',
                          onTap: _loadInvites,
                        ),
                      ],
                    ),
                  )
                else if (_invites.isEmpty)
                  _buildEmptyState()
                else ...[
                  // History list
                  Column(
                    children: [
                      for (int i = 0; i < _invites.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _buildHistoryItemCard(_invites[i]),
                      ],
                    ],
                  ),
                  if (!_hasActiveUnused) ...[
                    const SizedBox(height: 16),
                    CustomButton(
                      title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
                      isFilled: true,
                      backGroundColor: AppColors.primary,
                      titleStyle: 14.bold.copyWith(color: Colors.white),
                      prefixIcon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onTap: () => _generateAndSaveInvite(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
