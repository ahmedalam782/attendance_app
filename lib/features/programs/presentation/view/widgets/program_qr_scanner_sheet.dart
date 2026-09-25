import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/common/widgets/permission_confirmation_dialog.dart';
import '../../../../../core/common/widgets/scanner_overlay_painter.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class ProgramQrScannerSheet extends StatefulWidget {
  const ProgramQrScannerSheet({
    super.key,
    this.instruction,
  });

  /// Optional override for the bottom instruction label.
  final String? instruction;

  /// Shows the scanner sheet and returns the detected invite code (if any).
  static Future<String?> show(
    BuildContext context, {
    String? instruction,
  }) async {
    final confirmed = await PermissionConfirmationDialog.showCameraPermission(
      context,
    );
    if (!confirmed || !context.mounted) return null;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProgramQrScannerSheet(instruction: instruction),
    );
  }

  @override
  State<ProgramQrScannerSheet> createState() => _ProgramQrScannerSheetState();
}

class _ProgramQrScannerSheetState extends State<ProgramQrScannerSheet>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  bool _isTorchOn = false;
  bool _isProcessing = false;

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

  String _cleanCode(String raw) {
    var code = raw.trim();
    final lower = code.toLowerCase();
    const prefixes = [
      'attendance:program:',
      'attendance_app:program:',
      'attendance:instructor:',
      'attendance_app:instructor:',
      'program:',
      'instructor:',
    ];
    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        code = code.substring(prefix.length);
        break;
      }
    }
    return code.trim().toUpperCase();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        final parsed = _cleanCode(raw);
        if (parsed.isNotEmpty) {
          _isProcessing = true;
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop(parsed);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.75;
    final scanWindowSize = mediaQuery.size.width * 0.68;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: AppColors.scannerOverlay,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                          LocaleKeys.attendance_camera_permission_required.tr(),
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

            CustomPaint(
              painter: ScannerOverlayPainter(
                scanWindowSize: scanWindowSize,
                borderRadius: 24,
                borderWidth: 2.5,
              ),
            ),

            // Laser only — no extra container over the camera cutout
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
                              color: AppColors.scannerLaser.withValues(alpha: 0.75),
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

            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.scannerOnOverlay,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.darkSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: () async {
                      await _scannerController.toggleTorch();
                      if (mounted) {
                        setState(() => _isTorchOn = !_isTorchOn);
                      }
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
                          AppColors.darkSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.scannerFrame,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.instruction ??
                            LocaleKeys.programs_qr_scan_instruction.tr(),
                        style: 13.medium.copyWith(
                          color: AppColors.scannerOnOverlay,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
