import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
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
      maxHeightFactor: 0.94,
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
  bool _isRefreshing = false;

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
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    final token = await _tokenService.generateDynamicSessionToken(
      sessionId: widget.session.id,
      programId: widget.session.programId,
      sessionTitle: widget.session.title,
      windowSeconds: _windowSeconds,
    );

    if (mounted) {
      setState(() {
        _currentToken = token;
        _remainingSeconds = _windowSeconds;
        _isRefreshing = false;
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

  void _openFullscreenProjector(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => BlocProvider.value(
          value: context.read<AttendanceCubit>(),
          child: _FullscreenProjectorPage(
            session: widget.session,
            programTitle: widget.programTitle,
            tokenService: _tokenService,
            windowSeconds: _windowSeconds,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPadding(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row with Fullscreen Icon
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
                        widget.session.title,
                        style: 18.bold.copyWith(color: AppColors.slate900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.programTitle,
                        style: 12.medium.copyWith(color: AppColors.slate500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, color: AppColors.primary),
                  tooltip: LocaleKeys.dynamic_qr_fullscreen_mode.tr(),
                  onPressed: () => _openFullscreenProjector(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Anti-Share Protection Shield Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.emeraldLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.present.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 18,
                    color: AppColors.present,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.dynamic_qr_anti_share_badge.tr(),
                          style: 11.bold.copyWith(color: AppColors.present),
                        ),
                        Text(
                          LocaleKeys.dynamic_qr_anti_share_desc.tr(),
                          style: 10.regular.copyWith(color: AppColors.slate700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic QR Card
            QrCard(
              token: _currentToken,
              title: widget.session.title,
              subtitle: widget.programTitle,
              size: 160,
              footerText: LocaleKeys.dynamic_qr_time_window_hint.tr(),
            ),
            const SizedBox(height: 10),

            // Countdown timer pill & progress indicator + manual refresh button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      IconButton(
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                        tooltip: LocaleKeys.dynamic_qr_force_refresh.tr(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _isRefreshing ? null : _rotateToken,
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
            const SizedBox(height: 10),

            // Live Checked-In Count Banner
            BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, state) {
                final checkedInCount = state.records
                    .where((r) => r.sessionId == widget.session.id)
                    .length;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
                        LocaleKeys.dynamic_qr_students_scanned_count.tr(namedArgs: {
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
      ),
    );
  }

}

class _FullscreenProjectorPage extends StatefulWidget {
  const _FullscreenProjectorPage({
    required this.session,
    required this.programTitle,
    required this.tokenService,
    required this.windowSeconds,
  });

  final Session session;
  final String programTitle;
  final QrTokenService tokenService;
  final int windowSeconds;

  @override
  State<_FullscreenProjectorPage> createState() =>
      _FullscreenProjectorPageState();
}

class _FullscreenProjectorPageState extends State<_FullscreenProjectorPage> {
  String? _currentToken;
  int _remainingSeconds = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.windowSeconds;
    _rotateToken();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _rotateToken() async {
    final token = await widget.tokenService.generateDynamicSessionToken(
      sessionId: widget.session.id,
      programId: widget.session.programId,
      sessionTitle: widget.session.title,
      windowSeconds: widget.windowSeconds,
    );
    if (mounted) {
      setState(() {
        _currentToken = token;
        _remainingSeconds = widget.windowSeconds;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nowSeconds = DateTime.now().second % widget.windowSeconds;
      final remaining = widget.windowSeconds - nowSeconds;

      if (remaining == widget.windowSeconds || _currentToken == null) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.slate700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.title,
              style: 16.bold.copyWith(color: AppColors.slate900),
            ),
            Text(
              widget.programTitle,
              style: 11.medium.copyWith(color: AppColors.slate500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: LocaleKeys.dynamic_qr_force_refresh.tr(),
            onPressed: _rotateToken,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Anti-share badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldLight.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.present.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 16,
                            color: AppColors.present,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LocaleKeys.dynamic_qr_anti_share_badge.tr(),
                            style: 12.bold.copyWith(color: AppColors.present),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Giant QR Code
                    QrCard(
                      token: _currentToken,
                      title: widget.session.title,
                      subtitle: widget.programTitle,
                      size: 240,
                      footerText: LocaleKeys.dynamic_qr_time_window_hint.tr(),
                    ),
                    const SizedBox(height: 20),

                    // Countdown Pill
                    Container(
                      constraints: const BoxConstraints(maxWidth: 360),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.slate200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    LocaleKeys.dynamic_qr_refreshes_in.tr(
                                      namedArgs: {'seconds': '$_remainingSeconds'},
                                    ),
                                    style: 14.bold.copyWith(color: AppColors.slate900),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
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
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _remainingSeconds / widget.windowSeconds,
                              backgroundColor: AppColors.slate200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _remainingSeconds <= 5
                                    ? AppColors.late
                                    : AppColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Checked-In Count Banner
                    BlocBuilder<AttendanceCubit, AttendanceState>(
                      builder: (context, state) {
                        final checkedInCount = state.records
                            .where((r) => r.sessionId == widget.session.id)
                            .length;

                        return Container(
                          constraints: const BoxConstraints(maxWidth: 360),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_alt_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                LocaleKeys.dynamic_qr_students_scanned_count.tr(
                                  namedArgs: {'count': '$checkedInCount'},
                                ),
                                style: 13.bold.copyWith(color: AppColors.slate800),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

