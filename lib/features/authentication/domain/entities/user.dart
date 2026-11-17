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

enum AgeGroup { teen, adult, unknown }

enum CycleRegularity { regular, irregular, unsure }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    this.notifications = const NotificationPreferences(),
    this.ageGroup = AgeGroup.unknown,
    this.regularity = CycleRegularity.unsure,
    this.cycleSetupCompleted = false,
  });

  final String id;
  final String name;
  final String email;
  final int averageCycleLength;
  final int averagePeriodDuration;
  final NotificationPreferences notifications;
  final AgeGroup ageGroup;
  final CycleRegularity regularity;

  final bool cycleSetupCompleted;

  User copyWith({
    String? name,
    String? email,
    int? averageCycleLength,
    int? averagePeriodDuration,
    NotificationPreferences? notifications,
    AgeGroup? ageGroup,
    CycleRegularity? regularity,
    bool? cycleSetupCompleted,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration: averagePeriodDuration ?? this.averagePeriodDuration,
      notifications: notifications ?? this.notifications,
      ageGroup: ageGroup ?? this.ageGroup,
      regularity: regularity ?? this.regularity,
      cycleSetupCompleted: cycleSetupCompleted ?? this.cycleSetupCompleted,
    );
  }
}
