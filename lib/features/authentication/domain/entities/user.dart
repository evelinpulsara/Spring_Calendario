/// Reminder settings chosen by the user.
class NotificationPreferences {
  const NotificationPreferences({
    this.periodReminders = true,
    this.fertileWindowAlerts = false,
    this.dailyLogReminder = true,
  });

  final bool periodReminders;
  final bool fertileWindowAlerts;
  final bool dailyLogReminder;

  NotificationPreferences copyWith({
    bool? periodReminders,
    bool? fertileWindowAlerts,
    bool? dailyLogReminder,
  }) {
    return NotificationPreferences(
      periodReminders: periodReminders ?? this.periodReminders,
      fertileWindowAlerts: fertileWindowAlerts ?? this.fertileWindowAlerts,
      dailyLogReminder: dailyLogReminder ?? this.dailyLogReminder,
    );
  }
}

/// Application user. Cycle settings are used as fallbacks for predictions.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    this.notifications = const NotificationPreferences(),
  });

  final String id;
  final String name;
  final String email;
  final int averageCycleLength;
  final int averagePeriodDuration;
  final NotificationPreferences notifications;

  User copyWith({
    String? name,
    String? email,
    int? averageCycleLength,
    int? averagePeriodDuration,
    NotificationPreferences? notifications,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration: averagePeriodDuration ?? this.averagePeriodDuration,
      notifications: notifications ?? this.notifications,
    );
  }
}
