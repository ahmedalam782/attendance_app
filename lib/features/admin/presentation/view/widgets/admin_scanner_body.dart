import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/common/widgets/pending_sync_badge.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../attendance/presentation/view/widgets/scan_feedback_overlay.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_state.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../programs/presentation/view_model/cubit/programs_state.dart';

class AdminScannerBody extends StatefulWidget {
  const AdminScannerBody({super.key});

  @override
  State<AdminScannerBody> createState() => _AdminScannerBodyState();
}

class _AdminScannerBodyState extends State<AdminScannerBody> {
  MobileScannerController? _scannerController;
  bool _isCameraActive = false;
  bool _isTorchOn = false;

  String get _adminUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (_adminUid.isNotEmpty) {
      context.read<ProgramsCubit>().watchAdminPrograms(_adminUid);
    }
  }

  void _startCamera() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() => _isCameraActive = true);
  }

  void _stopCamera() {
    _scannerController?.dispose();
    _scannerController = null;
    setState(() {
      _isCameraActive = false;
      _isTorchOn = false;
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        context.read<AttendanceCubit>().processScannedCode(
              code,
              scannedBy: _adminUid,
            );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, attendanceState) {
        return Stack(
          children: [
            const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
            SafeArea(
              child: _isCameraActive
                  ? _buildCameraView(context, attendanceState)
                  : _buildReadyView(context, attendanceState),
            ),
            if (attendanceState.lastFeedback != null)
              ScanFeedbackOverlay(
                feedback: attendanceState.lastFeedback!,
                onDismiss: () =>
                    context.read<AttendanceCubit>().clearFeedback(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReadyView(
    BuildContext context,
    AttendanceState attendanceState,
  ) {
    return BlocBuilder<ProgramsCubit, ProgramsState>(
      builder: (context, programsState) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeaturePageHeader(
                          title: LocaleKeys.admin_scanner_title.tr(),
                          subtitle: LocaleKeys.admin_scanner_subtitle.tr(),
                          showOfflinePill: true,
                          trailing: PendingSyncBadge(
                            pendingCount: attendanceState.pendingSyncCount,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Active Session Selector Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.attendance_active_session.tr(),
                                style: 12.bold.copyWith(color: AppColors.slate500),
                              ),
                              const SizedBox(height: 8),
                              if (attendanceState.activeSession != null) ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.emeraldLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.event_available_rounded,
                                        size: 18,
                                        color: AppColors.present,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            attendanceState.activeSession!.title,
                                            style: 15.bold.copyWith(
                                              color: AppColors.slate900,
                                            ),
                                          ),
                                          Text(
                                            LocaleKeys.attendance_scanned_count
                                                .tr(
                                              namedArgs: {
                                                'count': attendanceState
                                                    .scanCount
                                                    .toString(),
                                              },
                                            ),
                                            style: 12.medium.copyWith(
                                              color: AppColors.present,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => context
                                          .read<AttendanceCubit>()
                                          .setActiveSession(null),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppColors.slate400,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text(
                                  programsState.programs.isEmpty
                                      ? LocaleKeys.attendance_no_open_sessions.tr()
                                      : LocaleKeys.attendance_select_session_hint
                                          .tr(),
                                  style: 13.regular
                                      .copyWith(color: AppColors.slate600),
                                ),
                                if (programsState.programs.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    LocaleKeys.attendance_no_open_sessions.tr(),
                                    style: 12.medium.copyWith(
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Scanner Ready Graphic
                        Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 44,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  LocaleKeys.admin_scanner_ready.tr(),
                                  style: 14.bold
                                      .copyWith(color: AppColors.slate900),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  LocaleKeys.admin_scanner_offline.tr(),
                                  style: 11.medium
                                      .copyWith(color: AppColors.slate400),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        CustomButton(
                          title: LocaleKeys.admin_scanner_open_camera.tr(),
                          prefixIcon: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.originalWhite,
                            size: 18,
                          ),
                          onTap: _startCamera,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCameraView(
    BuildContext context,
    AttendanceState attendanceState,
  ) {
    return Stack(
      children: [
        // Live camera
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),

        // Dark viewfinder framing overlay
        CustomPaint(
          size: Size.infinite,
          painter: _ScannerFramingPainter(),
        ),

        // Top bar
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Row(
            children: [
              IconButton.filled(
                onPressed: _stopCamera,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.scannerOnOverlay,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkSurface.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              IconButton.filled(
                onPressed: () {
                  _scannerController?.toggleTorch();
                  setState(() => _isTorchOn = !_isTorchOn);
                },
                icon: Icon(
                  _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isTorchOn
                      ? AppColors.late
                      : AppColors.scannerOnOverlay,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkSurface.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _scannerController?.switchCamera(),
                icon: const Icon(
                  Icons.cameraswitch_rounded,
                  color: AppColors.scannerOnOverlay,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkSurface.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),

        // Bottom status & counter
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.scannerFrame.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.present,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attendanceState.activeSession?.title ??
                            LocaleKeys.attendance_scanner_title.tr(),
                        style: 13.bold.copyWith(
                          color: AppColors.scannerOnOverlay,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        LocaleKeys.attendance_scan_target_hint.tr(),
                        style: 11.regular.copyWith(
                          color: AppColors.scannerOnOverlay
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${attendanceState.scanCount} Scanned',
                    style: 11.bold.copyWith(color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerFramingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanSize = size.width * 0.72;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2.3;
    final rect = Rect.fromLTWH(left, top, scanSize, scanSize);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Dark background cutout
    final bgPaint = Paint()..color = AppColors.scannerOverlay;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, bgPaint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = AppColors.scannerFrame
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + 14)
        ..arcToPoint(Offset(left + 14, top), radius: const Radius.circular(14))
        ..lineTo(left + cornerLength, top),
      bracketPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanSize - cornerLength, top)
        ..lineTo(left + scanSize - 14, top)
        ..arcToPoint(
          Offset(left + scanSize, top + 14),
          radius: const Radius.circular(14),
        )
        ..lineTo(left + scanSize, top + cornerLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanSize - cornerLength)
        ..lineTo(left, top + scanSize - 14)
        ..arcToPoint(
          Offset(left + 14, top + scanSize),
          radius: const Radius.circular(14),
        )
        ..lineTo(left + cornerLength, top + scanSize),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanSize - cornerLength, top + scanSize)
        ..lineTo(left + scanSize - 14, top + scanSize)
        ..arcToPoint(
          Offset(left + scanSize, top + scanSize - 14),
          radius: const Radius.circular(14),
        )
        ..lineTo(left + scanSize, top + scanSize - cornerLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
