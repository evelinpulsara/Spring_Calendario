import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/l10n/app_localizations.dart';
import 'package:lunaflow/core/l10n/locale_controller.dart';
import 'package:lunaflow/core/routes/app_routes.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/theme/theme_controller.dart';
import 'package:lunaflow/features/authentication/domain/entities/user.dart';
import 'package:lunaflow/features/authentication/presentation/controllers/session_controller.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';
import 'package:lunaflow/shared/widgets/section_title.dart';

/// Profile and settings: personal info, cycle defaults, notifications,
/// theme, language and privacy.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late double _cycleLength;
  late double _periodDuration;
  late NotificationPreferences _notifications;

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionController>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _cycleLength = (user?.averageCycleLength ?? AppConstants.defaultCycleLength).toDouble();
    _periodDuration =
        (user?.averagePeriodDuration ?? AppConstants.defaultPeriodDuration).toDouble();
    _notifications = user?.notifications ?? const NotificationPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final session = context.read<SessionController>();
    final messenger = ScaffoldMessenger.of(context);
    final user = session.user;
    if (user == null) return;
    final name = _nameController.text.trim();
    await session.updateProfile(user.copyWith(
      name: name.isEmpty ? user.name : name,
      averageCycleLength: _cycleLength.round(),
      averagePeriodDuration: _periodDuration.round(),
      notifications: _notifications,
    ));
    messenger.showSnackBar(SnackBar(content: Text(t.profileUpdated)));
  }

  Future<void> _deleteData() async {
    final t = AppLocalizations.of(context);
    final cycle = context.read<CycleController>();
    final symptoms = context.read<SymptomController>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t2 = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(t2.deleteConfirmTitle),
          content: Text(t2.deleteConfirmBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t2.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t2.delete)),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await cycle.clearData();
    await symptoms.clearData();
    messenger.showSnackBar(SnackBar(content: Text(t.dataDeleted)));
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await context.read<SessionController>().logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final email = context.read<SessionController>().user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ── Avatar / name ──────────────────────────────────────────
            LunarCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.purple,
                    child: Text(
                      _nameController.text.isEmpty
                          ? '?'
                          : _nameController.text[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(email, style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                        labelText: t.name,
                        prefixIcon: const Icon(Icons.person_outline)),
                  ),
                ],
              ),
            ),

            // ── Cycle settings ─────────────────────────────────────────
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.cycleSettings),
                  Text('${t.avgCycleLen}: ${_cycleLength.round()} ${t.days_label}'),
                  Slider(
                    value: _cycleLength,
                    min: 21,
                    max: 40,
                    divisions: 19,
                    onChanged: (v) => setState(() => _cycleLength = v),
                  ),
                  Text('${t.avgPeriodDur}: ${_periodDuration.round()} ${t.days_label}'),
                  Slider(
                    value: _periodDuration,
                    min: 2,
                    max: 10,
                    divisions: 8,
                    onChanged: (v) => setState(() => _periodDuration = v),
                  ),
                  Text(
                    t.mvpNote,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // ── Notifications ──────────────────────────────────────────
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.notifications),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.periodReminder),
                    value: _notifications.periodReminders,
                    onChanged: (v) => setState(
                        () => _notifications = _notifications.copyWith(periodReminders: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.fertileAlert),
                    value: _notifications.fertileWindowAlerts,
                    onChanged: (v) => setState(
                        () => _notifications =
                            _notifications.copyWith(fertileWindowAlerts: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.dailyReminder),
                    value: _notifications.dailyLogReminder,
                    onChanged: (v) => setState(
                        () => _notifications =
                            _notifications.copyWith(dailyLogReminder: v)),
                  ),
                  Text(t.notifNote,
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),

            // ── Theme ──────────────────────────────────────────────────
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.theme),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                            value: ThemeMode.light, label: Text(t.light)),
                        ButtonSegment(
                            value: ThemeMode.dark, label: Text(t.dark)),
                        ButtonSegment(
                            value: ThemeMode.system, label: Text(t.system)),
                      ],
                      selected: {themeController.themeMode},
                      onSelectionChanged: (s) =>
                          themeController.setThemeMode(s.first),
                    ),
                  ),
                ],
              ),
            ),

            // ── Language / Idioma ──────────────────────────────────────
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.language),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'en',
                          label: Text('English'),
                          icon: Text('🇺🇸',
                              style: TextStyle(fontSize: 18)),
                        ),
                        ButtonSegment(
                          value: 'es',
                          label: Text('Español'),
                          icon: Text('🇲🇽',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ],
                      selected: {localeController.locale.languageCode},
                      onSelectionChanged: (s) => localeController
                          .setLocale(Locale(s.first)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Privacy ────────────────────────────────────────────────
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t.privacy),
                  Text(
                    '${t.privacyNote} ${AppConstants.disclaimer}',
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteData,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(t.deleteData),
                  ),
                ],
              ),
            ),

            ElevatedButton(onPressed: _save, child: Text(t.saveChanges)),
            const SizedBox(height: 8),
            TextButton(onPressed: _logout, child: Text(t.logOut)),
          ],
        ),
      ),
    );
  }
}
