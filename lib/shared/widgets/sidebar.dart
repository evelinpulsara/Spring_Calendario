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
        children: [
          const MoonWidget(size: 40, progress: 0.35),
          const SizedBox(height: 10),
          toggle,
        ],
      );
    }
    return Row(
      children: [
        const MoonWidget(size: 40, progress: 0.35),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            AppConstants.appName,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: isLight ? AppColors.deepPurple : Colors.white,
            ),
          ),
        ),
        toggle,
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final Destination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final selected = widget.selected;
    final fg = selected
        ? (isLight ? AppColors.deepPurple : Colors.white)
        : (isLight ? const Color(0xFF4A4060) : Colors.white70);
    final bg = selected
        ? (isLight ? AppColors.lavender : AppColors.purple.withAlpha(120))
        : _hover
            ? AppColors.purple.withAlpha(isLight ? 18 : 40)
            : Colors.transparent;

    final item = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 6),
          padding: EdgeInsets.symmetric(horizontal: widget.expanded ? 14 : 0, vertical: 12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment:
                widget.expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected || _hover ? 1.1 : 1,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selected ? widget.destination.selectedIcon : widget.destination.icon,
                  color: selected ? AppColors.purple : fg,
                ),
              ),
              if (widget.expanded) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.destination.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration:
                        const BoxDecoration(color: AppColors.deepPink, shape: BoxShape.circle),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return widget.expanded ? item : Tooltip(message: widget.destination.label, child: item);
  }
}

/// Parte de abajo: usuaria y cambio de tema.
class _Footer extends StatelessWidget {
  const _Footer({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final user = context.watch<SessionController>().user;
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.themeMode == ThemeMode.dark;
    final name = user?.name ?? AppLanguage.tr('Invitada', 'Guest');

    final themeButton = IconButton(
      tooltip: isDark
          ? AppLanguage.tr('Tema claro', 'Light theme')
          : AppLanguage.tr('Tema oscuro', 'Dark theme'),
      onPressed: () =>
          themeController.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: AppColors.purple,
        ),
      ),
    );

    final avatar = CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.softPink,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: const TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.w800),
