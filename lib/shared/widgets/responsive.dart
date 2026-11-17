import 'package:flutter/material.dart';
import 'package:spring_calendario/shared/widgets/animations.dart';

class Breakpoints {
  Breakpoints._();

  static const double wide = 900;

  static const double extendedMenu = 1200;

  static const double twoColumns = 760;

  static const double maxContentWidth = 1180;

  static bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= wide;
}

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
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CenteredContent extends StatelessWidget {
  const CenteredContent({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
