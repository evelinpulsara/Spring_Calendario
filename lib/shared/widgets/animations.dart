import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';

/// Aparece con un desvanecido y un pequeño desplazamiento hacia arriba.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offsetY = 24,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY * (1 - _curve.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Envuelve cada elemento para que aparezcan uno tras otro.
List<Widget> staggered(List<Widget> children, {Duration step = const Duration(milliseconds: 70)}) {
  return [
    for (var i = 0; i < children.length; i++)
      FadeSlideIn(delay: step * math.min(i, 8), child: children[i]),
  ];
}

/// Se encoge un poco al presionarlo, como un botón suave.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Fondo con manchas de color suaves que flotan lentamente.
class SoftBackground extends StatefulWidget {
  const SoftBackground({super.key, required this.child});

  final Widget child;

  @override
  State<SoftBackground> createState() => _SoftBackgroundState();
}

class _SoftBackgroundState extends State<SoftBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final alpha = isLight ? 110 : 45;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value * 2 * math.pi;
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                    child: Stack(
                      children: [
                        _blob(
                          left: -60 + 30 * math.sin(t),
                          top: -40 + 20 * math.cos(t),
                          size: 260,
                          color: AppColors.lavender.withAlpha(alpha + 60),
                        ),
                        _blob(
                          right: -80 + 25 * math.cos(t),
                          top: 180 + 30 * math.sin(t),
                          size: 240,
                          color: AppColors.softPink.withAlpha(alpha),
                        ),
                        _blob(
                          left: 40 + 20 * math.cos(t + 1),
                          bottom: -60 + 25 * math.sin(t + 1),
                          size: 220,
                          color: AppColors.purple.withAlpha(alpha ~/ 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _blob({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// Como IndexedStack (conserva el estado de cada pestaña), pero con una
/// transición suave al cambiar de pestaña.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(curve),
        child: IndexedStack(index: widget.index, children: widget.children),
      ),
    );
  }
}

/// Transición entre pantallas: desvanecido con un leve deslizamiento.
class SoftPageRoute<T> extends PageRouteBuilder<T> {
  SoftPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (context, animation, _, child) {
            final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curve),
                child: child,
              ),
            );
          },
        );
}

/// Tres puntitos que saltan (para "Spring está pensando...").
class ThinkingDots extends StatefulWidget {
  const ThinkingDots({super.key, this.color = AppColors.purple});

  final Color color;

  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Transform.translate(
              offset: Offset(0, -4 * math.max(0, math.sin((_controller.value * 2 * math.pi) - i * 0.9))),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
