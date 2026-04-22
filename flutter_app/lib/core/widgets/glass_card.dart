import 'dart:ui';

import 'package:flutter/cupertino.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: child,
        ),
      ),
    );
  }
}
