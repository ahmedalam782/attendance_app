import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/centered_scroll_body.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/crypto/qr_token_service.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class StudentQrBody extends StatefulWidget {
  const StudentQrBody({super.key});

  @override
  State<StudentQrBody> createState() => _StudentQrBodyState();
}

class _StudentQrBodyState extends State<StudentQrBody> {
  String? _token;
  double? _previousBrightness;

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _studentId => _user?.uid ?? 'guest';
  String get _studentName =>
      _user?.displayName ?? _user?.email?.split('@').first ?? 'Student';

  @override
  void initState() {
    super.initState();
    _loadToken();
    _increaseBrightness();
  }

  Future<void> _loadToken() async {
    final service = QrTokenService();
    final token = await service.generateToken(
      studentId: _studentId,
      studentName: _studentName,
    );
    if (mounted) {
      setState(() => _token = token);
    }
  }

  Future<void> _increaseBrightness() async {
    try {
      _previousBrightness = await ScreenBrightness().application;
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (_) {
      // Screen brightness might not be supported on desktop/web/simulators
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      if (_previousBrightness != null) {
        await ScreenBrightness().setApplicationScreenBrightness(_previousBrightness!);
      } else {
        await ScreenBrightness().resetApplicationScreenBrightness();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _restoreBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
        SafeArea(
          child: CenteredScrollBody(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeaturePageHeader(
                  title: LocaleKeys.student_my_qr_title.tr(),
                  subtitle: LocaleKeys.student_my_qr_subtitle.tr(),
                  showOfflinePill: true,
                ),
                const SizedBox(height: 24),
                Center(
                  child: _token != null
                      ? QrCard(
                          token: _token!,
                          studentName: _studentName,
                          studentId: _studentId,
                          size: 210,
                        )
                      : Container(
                          width: 250,
                          height: 320,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                const _QrBrightnessHintCard(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QrBrightnessHintCard extends StatelessWidget {
  const _QrBrightnessHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LocaleKeys.student_qr_brightness_hint.tr(),
              style: 11.regular.copyWith(color: AppColors.slate600),
            ),
          ),
        ],
      ),
    );
  }
}
