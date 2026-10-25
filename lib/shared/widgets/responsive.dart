import 'package:flutter/material.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';

/// Puntos de quiebre del diseño adaptable.
///
/// * Celular: menos de [wide] -> barra de navegación abajo, una columna.
/// * Computadora / tablet: desde [wide] -> menú lateral, diseño de página web.
class Breakpoints {
  Breakpoints._();

  /// Desde este ancho de ventana la app se comporta como página web.
  static const double wide = 900;

  /// Desde este ancho el menú lateral muestra también los nombres.
  static const double extendedMenu = 1200;

  /// Ancho del contenido a partir del cual se usan dos columnas.
  static const double twoColumns = 760;

  /// Ancho máximo del contenido en pantallas grandes.
  static const double maxContentWidth = 1180;

  static bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= wide;
}

/// Página con fondo suave y tarjetas que aparecen una tras otra.
///
/// * En celular: una sola lista con [children] y luego [sideChildren].
/// * En computadora: contenido centrado con ancho máximo; si hay
///   [sideChildren] se muestran en una segunda columna a la derecha.
class StaggeredListView extends StatelessWidget {
  const StaggeredListView({
    super.key,
    this.padding,
    required this.children,
    this.sideChildren,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.mainFlex = 3,
    this.sideFlex = 2,
  });

  final EdgeInsetsGeometry? padding;
  final List<Widget> children;
  final List<Widget>? sideChildren;
  final double maxWidth;
  final int mainFlex;
  final int sideFlex;

  @override
  Widget build(BuildContext context) {
    return SoftBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = sideChildren;
          final wide = constraints.maxWidth >= Breakpoints.twoColumns;

          if (!wide) {
            return ListView(
              padding: padding,
              children: staggered([...children, ...?side]),
            );
          }

          final Widget content;
          if (side == null) {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: staggered(children),
            );
          } else {
            content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: mainFlex,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: staggered(children),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: sideFlex,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: staggered(side, step: const Duration(milliseconds: 90)),
                  ),
                ),
