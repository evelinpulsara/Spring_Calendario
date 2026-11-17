import 'package:spring_calendario/core/utils/date_utils.dart';

class DemoData {
  DemoData._();

  static const List<int> cycleLengths = [28, 29, 27, 30, 28];

  static const List<int> periodDurations = [5, 5, 4, 5, 6, 5];

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
