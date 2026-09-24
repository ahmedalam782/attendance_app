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
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'create_instructor_invite_sheet.dart';

/// Public body widget for [InstructorInviteCodePage] following Al Faris presentation architecture.
class InstructorInviteCodeBody extends StatefulWidget {
  const InstructorInviteCodeBody({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<InstructorInviteCodeBody> createState() =>
      _InstructorInviteCodeBodyState();
}

class _InstructorInviteCodeBodyState extends State<InstructorInviteCodeBody> {
  String? _selectedCode;
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

      final existingUnused = items.cast<InstructorInviteItem?>().firstWhere(
            (it) => it != null && !it.isUsed,
            orElse: () => null,
          );

      if (mounted) {
        setState(() {
          _invites = items;
          if (widget.initialCode != null) {
            _selectedCode = widget.initialCode;
          } else {
            _selectedCode = existingUnused?.code ??
                (items.isNotEmpty ? items.first.code : null);
          }
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

    // Strict guard: Do not create another code if an unused one already exists
    if (activeUnused != null) {
      CustomToast(
        context: context,
        header: isArabic
            ? 'يوجد كود نشط بالفعل لم يُستخدم بعد (${activeUnused.code})'
            : 'An active code already exists (${activeUnused.code})',
        type: ToastificationType.warning,
      ).showToast();
      setState(() {
        _selectedCode = activeUnused.code;
      });
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
          _selectedCode = code;
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
    return DateFormat('yyyy/MM/dd · hh:mm a').format(dt);
  }

  Widget _buildTopBar() {
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
                LocaleKeys.settings_extra_admin_create_invite_title.tr(),
                style: 16.bold.copyWith(color: AppColors.slate900),
              ),
              const SizedBox(height: 2),
              Text(
                LocaleKeys.settings_extra_admin_create_invite_subtitle.tr(),
                style: 11.medium.copyWith(color: AppColors.slate500),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: LocaleKeys.settings_extra_invite_tab_history.tr(),
          onPressed: () async {
            await context.router.push(const InstructorInvitesHistoryRoute());
            _loadInvites(); // Refresh when returning
          },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.slate100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(
            Icons.history_rounded,
            size: 20,
            color: AppColors.slate800,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isArabic = context.locale.languageCode == 'ar';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا يوجد كود دعوة حالياً' : 'No Invite Code Available',
            style: 15.bold.copyWith(color: AppColors.slate900),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic
                ? 'قم بإنشاء كود دعوة جديد لمشاركته مع المدرب.'
                : 'Generate a new invite code to share with the instructor.',
            style: 12.regular.copyWith(color: AppColors.slate500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          CustomButton(
            title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
            isFilled: true,
            backGroundColor: AppColors.primary,
            titleStyle: 13.bold.copyWith(color: Colors.white),
            prefixIcon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            onTap: () => _generateAndSaveInvite(),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard() {
    final currentItem = _invites.cast<InstructorInviteItem?>().firstWhere(
          (it) => it?.code == _selectedCode,
          orElse: () => null,
        );
    final isCurrentUsed = currentItem?.isUsed ?? false;

    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: QrCard(
              token: 'attendance:instructor:$_selectedCode',
              size: 160,
              footerText:
                  LocaleKeys.settings_extra_admin_qr_display_instruction.tr(),
              headerWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    _selectedCode!,
                    style: 22.bold.copyWith(
                      color: isCurrentUsed
                          ? AppColors.slate500
                          : AppColors.slate900,
                      letterSpacing: 2.0,
                      decoration: isCurrentUsed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isCurrentUsed
                              ? AppColors.present
                              : AppColors.absent)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: isCurrentUsed
                              ? AppColors.present
                              : AppColors.absent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCurrentUsed
                              ? LocaleKeys.settings_extra_invite_status_used.tr()
                              : LocaleKeys.settings_extra_invite_active_ready.tr(),
                          style: 11.bold.copyWith(
                            color: isCurrentUsed
                                ? AppColors.present
                                : AppColors.absent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCurrentUsed) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: LocaleKeys.settings_extra_admin_copy_code.tr(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.slate100,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(8),
                          ),
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _copyCode(_selectedCode),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: LocaleKeys.settings_extra_admin_share_code.tr(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.slate100,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(8),
                          ),
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _shareCode(_selectedCode),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isCurrentUsed && currentItem != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.slate200.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'تم التفعيل بواسطة' : 'Redeemed by',
                              style: 10.medium.copyWith(
                                color: AppColors.slate400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentItem.usedByName?.isNotEmpty == true
                                  ? currentItem.usedByName!
                                  : (currentItem.usedByEmail ??
                                      (isArabic ? 'مدرب مُفعَّل' : 'Active Instructor')),
                              style: 13.bold.copyWith(
                                color: AppColors.slate800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (currentItem.usedByEmail?.isNotEmpty == true &&
                      currentItem.usedByEmail != currentItem.usedByName) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.slate200),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.slate400,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentItem.usedByEmail!,
                            style: 11.medium.copyWith(
                              color: AppColors.slate600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (currentItem.redeemedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: AppColors.present,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'تاريخ التفعيل: ${_formatDate(currentItem.redeemedAt)}'
                                : 'Redeemed: ${_formatDate(currentItem.redeemedAt)}',
                            style: 11.medium.copyWith(
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
            isFilled: true,
            isGradient: false,
            backGroundColor: _hasActiveUnused
                ? AppColors.slate100
                : AppColors.primaryLight,
            borderColor: _hasActiveUnused
                ? AppColors.slate300
                : AppColors.primary,
            titleStyle: 13.bold.copyWith(
              color: _hasActiveUnused
                  ? AppColors.slate400
                  : AppColors.primary,
            ),
            prefixIcon: Icon(
              Icons.add_circle_outline_rounded,
              color: _hasActiveUnused
                  ? AppColors.slate400
                  : AppColors.primary,
              size: 18,
            ),
            onTap: () => _generateAndSaveInvite(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          title: LocaleKeys.settings_extra_admin_generate_new_code.tr(),
                          onTap: () => _generateAndSaveInvite(),
                        ),
                      ],
                    ),
                  )
                else if (_selectedCode == null)
                  _buildEmptyState()
                else
                  _buildCodeCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
