import 'package:flutter/material.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';

class SpringCard extends StatelessWidget {
  const SpringCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = const EdgeInsets.only(bottom: 16),
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radius = BorderRadius.circular(24);
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (isLight ? Colors.white : AppColors.darkSurface) : null,
        gradient: gradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withAlpha(isLight ? 38 : 20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return onTap == null ? card : PressableScale(child: card);
  }
}
