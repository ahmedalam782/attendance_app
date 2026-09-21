import 'package:flutter/material.dart';

/// Centers [child] in a scrollable area that fills available height.
class CenteredScrollBody extends StatelessWidget {
  const CenteredScrollBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
