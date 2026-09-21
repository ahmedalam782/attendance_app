import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../view_model/cubit/attendance_state.dart';

class ScanFeedbackOverlay extends StatefulWidget {
  const ScanFeedbackOverlay({
    super.key,
    required this.feedback,
    required this.onDismiss,
  });

  final ScanFeedback feedback;
  final VoidCallback onDismiss;

  @override
  State<ScanFeedbackOverlay> createState() => _ScanFeedbackOverlayState();
}

class _ScanFeedbackOverlayState extends State<ScanFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.feedback.type) {
      case ScanFeedbackType.present:
        return AppColors.present;
      case ScanFeedbackType.late:
        return AppColors.late;
      case ScanFeedbackType.duplicate:
      case ScanFeedbackType.invalid:
        return AppColors.absent;
    }
  }

  IconData get _icon {
    switch (widget.feedback.type) {
      case ScanFeedbackType.present:
        return Icons.check_circle_rounded;
      case ScanFeedbackType.late:
        return Icons.access_time_filled_rounded;
      case ScanFeedbackType.duplicate:
        return Icons.repeat_rounded;
      case ScanFeedbackType.invalid:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.feedback.studentName.isNotEmpty) ...[
                      Text(
                        widget.feedback.studentName,
                        style: 15.bold.copyWith(color: AppColors.slate900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      widget.feedback.message,
                      style: 13.medium.copyWith(color: _color),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _timer?.cancel();
                  widget.onDismiss();
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.slate400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
