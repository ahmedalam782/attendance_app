import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/crypto/qr_token_service.dart';
import '../../../../../core/dependency_injection/injectable_config.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_state.dart';
import '../../../domain/entities/session.dart';

class DynamicSessionQrSheet extends StatefulWidget {
  const DynamicSessionQrSheet({
    super.key,
    required this.session,
    required this.programTitle,
  });

  final Session session;
  final String programTitle;

  static Future<void> show(
    BuildContext context, {
    required Session session,
    required String programTitle,
  }) {
    return showAppSheet<void>(
      context,
      builder: (_) => BlocProvider.value(
        value: context.read<AttendanceCubit>(),
        child: DynamicSessionQrSheet(
          session: session,
          programTitle: programTitle,
        ),
      ),
    );
  }

  @override
  State<DynamicSessionQrSheet> createState() => _DynamicSessionQrSheetState();
}

class _DynamicSessionQrSheetState extends State<DynamicSessionQrSheet> {
  static const int _windowSeconds = 20;

  final QrTokenService _tokenService = getIt<QrTokenService>();
  String? _currentToken;
  int _remainingSeconds = _windowSeconds;
  Timer? _timer;
  double? _originalBrightness;

  @override
  void initState() {
    super.initState();
    _setMaxBrightness();
    _rotateToken();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restoreBrightness();
    super.dispose();
  }

  Future<void> _setMaxBrightness() async {
    try {
      _originalBrightness = await ScreenBrightness().application;
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }

  Future<void> _restoreBrightness() async {
    try {
      if (_originalBrightness != null) {
        await ScreenBrightness()
            .setApplicationScreenBrightness(_originalBrightness!);
      }
    } catch (_) {}
  }

  Future<void> _rotateToken() async {
    final token = await _tokenService.generateDynamicSessionToken(
      sessionId: widget.session.id,
      programId: widget.session.programId,
      sessionTitle: widget.session.title,
      windowSeconds: _windowSeconds,
    );
    if (mounted) {
      setState(() {
        _currentToken = token;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nowSeconds = DateTime.now().second % _windowSeconds;
      final remaining = _windowSeconds - nowSeconds;

      if (remaining == _windowSeconds || _currentToken == null) {
        _rotateToken();
      }

      if (mounted) {
        setState(() {
          _remainingSeconds = remaining;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.dynamic_qr_projector_mode.tr(),
                      style: 18.bold.copyWith(color: AppColors.slate900),
                    ),
                    Text(
                      '${widget.programTitle} • ${widget.session.title}',
                      style: 12.medium.copyWith(color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

              // Dynamic QR Card
              QrCard(
                token: _currentToken,
                title: widget.session.title,
                subtitle: widget.programTitle,
                size: 200,
                footerText: LocaleKeys.dynamic_qr_time_window_hint.tr(),
              ),
              const SizedBox(height: 16),

              // Countdown timer pill & progress indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocaleKeys.dynamic_qr_refreshes_in.tr(namedArgs: {
                            'seconds': '$_remainingSeconds',
                          }),
                          style: 13.bold.copyWith(color: AppColors.slate800),
                        ),
                        const Spacer(),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.present,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          LocaleKeys.dynamic_qr_session_active_broadcast.tr(),
                          style: 11.medium.copyWith(color: AppColors.present),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _remainingSeconds / _windowSeconds,
                        backgroundColor: AppColors.slate200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _remainingSeconds <= 5
                              ? AppColors.late
                              : AppColors.primary,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Live Checked-In Count Banner
              BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  final checkedInCount = state.records
                      .where((r) => r.sessionId == widget.session.id)
                      .length;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 16,
                          color: AppColors.slate600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocaleKeys.dynamic_qr_students_scanned_count
                              .tr(namedArgs: {
                            'count': '$checkedInCount',
                          }),
                          style: 12.bold.copyWith(color: AppColors.slate700),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
  }
}
