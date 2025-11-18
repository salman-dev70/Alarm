import 'package:intl/intl.dart';
import '../models/alarm_model.dart';

class FormatterUtil {
  // Time format: "07:30"
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Date format: "Mon, Jan 15"
  static String formatDate(DateTime time) {
    return DateFormat('EEE').format(time);
  }

  // Repeat type to text
  static String getRepeatText(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.once:
        return 'Once';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
    }
  }

  // DateTime to readable string: "Mon, Jan 15 at 07:30"
  static String formatDateTime(DateTime time) {
    return '${formatDate(time)} at ${formatTime(time)}';
  }
}
