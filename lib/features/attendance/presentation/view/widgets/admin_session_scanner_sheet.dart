import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/permission_confirmation_dialog.dart';
import '../../../../../core/common/widgets/scanner_overlay_painter.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../programs/domain/entities/program.dart';
import '../../../../sessions/domain/entities/session.dart';
import '../../view_model/cubit/attendance_cubit.dart';
import '../../view_model/cubit/attendance_state.dart';
import 'scan_feedback_overlay.dart';

/// Modal bottom sheet camera scanner dedicated to an instructor scanning student badges
/// for a specific [Session].
class AdminSessionScannerSheet extends StatefulWidget {
  const AdminSessionScannerSheet({
    super.key,
    required this.session,
    required this.program,
  });

  final Session session;
  final Program program;

  static Future<void> show(
    BuildContext context, {
    required Session session,
    required Program program,
  }) async {
    final confirmed = await PermissionConfirmationDialog.showCameraPermission(
      context,
    );
    if (!confirmed || !context.mounted) return;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AttendanceCubit>(),
        child: AdminSessionScannerSheet(
          session: session,
          program: program,
        ),
      ),
    );
  }

  @override
  State<AdminSessionScannerSheet> createState() =>
      _AdminSessionScannerSheetState();
}

class _AdminSessionScannerSheetState extends State<AdminSessionScannerSheet>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  bool _isTorchOn = false;

  String get _adminUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().setActiveSession(widget.session);

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
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
    final size = MediaQuery.sizeOf(context);
    final scanWindowSize = size.width * 0.70;

    return Container(
      height: size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.scannerOverlay,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, attendanceState) {
            return Stack(
              children: [
                // Camera View
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.no_photography_rounded,
                              size: 48,
                              color: AppColors.absent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              LocaleKeys.attendance_camera_permission_required.tr(),
                              textAlign: TextAlign.center,
                              style: 14.bold.copyWith(color: AppColors.originalWhite),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              title: LocaleKeys.attendance_grant_permission.tr(),
                              onTap: () async {
                                final granted = await PermissionConfirmationDialog
                                    .showCameraPermission(context);
                                if (granted && mounted) {
                                  _scannerController.start();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Viewfinder Framing Overlay
                CustomPaint(
                  size: Size.infinite,
                  painter: ScannerOverlayPainter(
                    scanWindowSize: scanWindowSize,
                    borderRadius: 20,
                  ),
                ),

                // Animated Laser Line
                Center(
                  child: SizedBox(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    child: AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment(
                            0,
                            (_laserController.value * 2) - 1,
                          ),
                          child: Container(
                            height: 2,
                            width: scanWindowSize - 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.1),
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Top Bar
                Positioned(
                  top: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      IconButton.filled(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.scannerOnOverlay,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.darkSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.session.title,
                              style: 14.bold.copyWith(
                                color: AppColors.scannerOnOverlay,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.program.title,
                              style: 11.medium.copyWith(
                                color: AppColors.scannerOnOverlay
                                    .withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          _scannerController.toggleTorch();
                          setState(() => _isTorchOn = !_isTorchOn);
                        },
                        icon: Icon(
                          _isTorchOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: _isTorchOn
                              ? AppColors.late
                              : AppColors.scannerOnOverlay,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.darkSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => _scannerController.switchCamera(),
                        icon: const Icon(
                          Icons.cameraswitch_rounded,
                          color: AppColors.scannerOnOverlay,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.darkSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Status Pill
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
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
                                LocaleKeys.attendance_scanner_title.tr(),
                                style: 13.bold.copyWith(
                                  color: AppColors.scannerOnOverlay,
                                ),
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

                // Feedback Banner Overlay
                if (attendanceState.lastFeedback != null)
                  ScanFeedbackOverlay(
                    feedback: attendanceState.lastFeedback!,
                    onDismiss: () =>
                        context.read<AttendanceCubit>().clearFeedback(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
