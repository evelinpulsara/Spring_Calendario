import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/routes/app_routes.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/theme/theme_controller.dart';
import 'package:lunaflow/features/authentication/domain/entities/user.dart';
import 'package:lunaflow/features/authentication/presentation/controllers/session_controller.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:lunaflow/shared/widgets/lunar_card.dart';
import 'package:lunaflow/shared/widgets/section_title.dart';

/// Profile and settings: personal info, cycle defaults, notifications, theme, privacy.
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
    messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _deleteData() async {
    final cycle = context.read<CycleController>();
    final symptoms = context.read<SymptomController>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text('All period days and symptoms will be removed from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await cycle.clearData();
    await symptoms.clearData();
    messenger.showSnackBar(const SnackBar(content: Text('Your data was deleted')));
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await context.read<SessionController>().logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final email = context.read<SessionController>().user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            LunarCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.purple,
                    child: Text(
                      _nameController.text.isEmpty ? '?' : _nameController.text[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 28, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(email, style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                  ),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Cycle settings'),
                  Text('Average cycle length: ${_cycleLength.round()} days'),
                  Slider(
                    value: _cycleLength,
                    min: 21,
                    max: 40,
                    divisions: 19,
                    onChanged: (v) => setState(() => _cycleLength = v),
                  ),
                  Text('Average period duration: ${_periodDuration.round()} days'),
                  Slider(
                    value: _periodDuration,
                    min: 2,
                    max: 10,
                    divisions: 8,
                    onChanged: (v) => setState(() => _periodDuration = v),
                  ),
                  const Text(
                    'Used until LunaFlow has enough logged data to calculate your own averages.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Notifications'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Period reminders'),
                    value: _notifications.periodReminders,
                    onChanged: (v) => setState(
                        () => _notifications = _notifications.copyWith(periodReminders: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fertile window alerts'),
                    value: _notifications.fertileWindowAlerts,
                    onChanged: (v) => setState(
                        () => _notifications = _notifications.copyWith(fertileWindowAlerts: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daily log reminder'),
                    value: _notifications.dailyLogReminder,
                    onChanged: (v) => setState(
                        () => _notifications = _notifications.copyWith(dailyLogReminder: v)),
                  ),
                  const Text('Preferences are saved, but no real notifications are sent in the MVP.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Theme'),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                        ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ],
                      selected: {themeController.themeMode},
                      onSelectionChanged: (s) => themeController.setThemeMode(s.first),
                    ),
                  ),
                ],
              ),
            ),
            LunarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Privacy'),
                  const Text(
                    'In this MVP your data is kept only in the app memory and is never sent '
                    'to a server. ${AppConstants.disclaimer}',
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteData,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete all my data'),
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: _save, child: const Text('Save changes')),
            const SizedBox(height: 8),
            TextButton(onPressed: _logout, child: const Text('Log out')),
          ],
        ),
      ),
    );
  }
}
