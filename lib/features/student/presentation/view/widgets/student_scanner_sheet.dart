import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/common/widgets/permission_confirmation_dialog.dart';
import '../../../../../core/common/widgets/scanner_overlay_painter.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../attendance/presentation/view/widgets/scan_feedback_overlay.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_state.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';

class StudentScannerSheet extends StatefulWidget {
  const StudentScannerSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final confirmed = await PermissionConfirmationDialog.showCameraPermission(
      context,
    );
    if (!confirmed || !context.mounted) return;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AttendanceCubit>()),
          BlocProvider.value(value: context.read<ProgramsCubit>()),
        ],
        child: const StudentScannerSheet(),
      ),
    );
  }

  @override
  State<StudentScannerSheet> createState() => _StudentScannerSheetState();
}

class _StudentScannerSheetState extends State<StudentScannerSheet>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  bool _isTorchOn = false;
  bool _isProcessing = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;
  String get _studentId => _currentUser?.uid ?? '';
  String get _studentName =>
      _currentUser?.displayName ??
      _currentUser?.email?.split('@').first ??
      'Student';

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isProcessing = true);

        final enrolledPrograms =
            context.read<ProgramsCubit>().state.programs;
        final enrolledProgramIds = enrolledPrograms.map((p) => p.id).toList();

        final success =
            await context.read<AttendanceCubit>().processSelfCheckIn(
                  rawCode: code,
                  studentId: _studentId,
                  studentName: _studentName,
                  enrolledProgramIds: enrolledProgramIds,
                );

        if (mounted) {
          setState(() => _isProcessing = false);
          if (success) {
            // Dismiss scanner after a brief delay so student sees success flash
            Future.delayed(const Duration(milliseconds: 2200), () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanWindowSize = size.width * 0.70;

    return Container(
      height: size.height * 0.88,
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
                            const SizedBox(height: 12),
                            Text(
                              LocaleKeys.attendance_camera_permission_required
                                  .tr(),
                              textAlign: TextAlign.center,
                              style: 13.bold
                                  .copyWith(color: AppColors.originalWhite),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Darkened background with transparent center cutout
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(
                      scanWindowSize: scanWindowSize,
                      borderRadius: 24,
                      borderWidth: 2.5,
                    ),
                  ),
                ),

                // Viewfinder laser sweep
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
                            -1.0 + (2.0 * _laserController.value),
                          ),
                          child: Container(
                            height: 2.5,
                            width: scanWindowSize - 20,
                            decoration: BoxDecoration(
                              color: AppColors.scannerLaser,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.scannerLaser
                                      .withValues(alpha: 0.75),
                                  blurRadius: 10,
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

                // Header Controls
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.scannerOnOverlay, size: 26),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.darkSurface
                                .withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                LocaleKeys.self_check_in_scan_session_qr.tr(),
                                style: 17.bold.copyWith(
                                  color: AppColors.scannerOnOverlay,
                                ),
                              ),
                              Text(
                                LocaleKeys.self_check_in_scan_session_qr_desc
                                    .tr(),
                                style: 11.medium.copyWith(
                                  color: AppColors.scannerOnOverlay
                                      .withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _scannerController.toggleTorch();
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                          icon: Icon(
                            _isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: _isTorchOn
                                ? AppColors.amber
                                : AppColors.scannerOnOverlay,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.darkSurface
                                .withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Instruction Badge
                Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.scannerFrame.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.center_focus_strong_rounded,
                            color: AppColors.scannerFrame,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              LocaleKeys.self_check_in_scan_session_qr_desc
                                  .tr(),
                              style: 12.medium.copyWith(
                                color: AppColors.scannerOnOverlay,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Feedback Overlay (Green / Amber / Red flash)
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
