import 'package:lunaflow/core/utils/date_utils.dart';

/// Shared helpers used by the in-memory repositories to create demo history.
class DemoData {
  DemoData._();

  /// Length (in days) of each past cycle, newest first.
  static const List<int> cycleLengths = [28, 29, 27, 30, 28];

  /// Period duration of each cycle, newest first (one more than [cycleLengths]).
  static const List<int> periodDurations = [5, 5, 4, 5, 6, 5];

  /// Period start dates ordered from newest to oldest.
  /// The newest cycle started 9 days ago so the dashboard shows cycle day 10.
  static List<DateTime> periodStarts() {
    var start = AppDateUtils.addDays(AppDateUtils.today(), -9);
    final starts = <DateTime>[start];
    for (final length in cycleLengths) {
      start = AppDateUtils.addDays(start, -length);
      starts.add(start);
    }
    return starts;
  }
}
