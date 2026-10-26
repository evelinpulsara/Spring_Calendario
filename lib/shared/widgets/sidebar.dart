import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/theme/theme_controller.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/shared/widgets/main_shell.dart';
import 'package:spring_calendario/shared/widgets/moon_widget.dart';

/// Menú lateral para computadora. Se puede esconder (solo iconos) o mostrar
/// completo con el botón de arriba.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.expanded,
    required this.onToggle,
  });

  final List<Destination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool expanded;
  final VoidCallback onToggle;

  static const double expandedWidth = 248;
  static const double collapsedWidth = 84;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: expanded ? expandedWidth : collapsedWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLight
              ? const [Colors.white, AppColors.lavenderSoft]
              : const [AppColors.darkSurface, AppColors.night],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withAlpha(isLight ? 25 : 40),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          maxWidth: expanded ? expandedWidth : collapsedWidth,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(expanded: expanded, onToggle: onToggle),
                  const SizedBox(height: 28),
                  for (var i = 0; i < destinations.length; i++)
                    _SidebarItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      expanded: expanded,
                      onTap: () => onSelected(i),
                    ),
                  const Spacer(),
                  _Footer(expanded: expanded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final toggle = IconButton(
      tooltip: expanded
          ? AppLanguage.tr('Esconder menú', 'Collapse menu')
          : AppLanguage.tr('Mostrar menú', 'Expand menu'),
      onPressed: onToggle,
      icon: AnimatedRotation(
        turns: expanded ? 0 : 0.5,
        duration: const Duration(milliseconds: 280),
        child: const Icon(Icons.keyboard_double_arrow_left_rounded),
      ),
      color: AppColors.textMuted,
    );

    if (!expanded) {
      return Column(
