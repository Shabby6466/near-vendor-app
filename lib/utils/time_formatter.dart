import 'package:jiffy/jiffy.dart';

class TimeFormatter {
  TimeFormatter._();

  /// Returns a relative time string like "2 hours ago", "a few seconds ago".
  /// Returns empty string if [date] is null.
  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    return Jiffy.parseFromDateTime(date).fromNow();
  }

  /// Returns "Edited · {timeAgo}" if [isEdited] is true, otherwise just {timeAgo}.
  static String editedTimeAgo({
    required bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final time = timeAgo(isEdited == true ? updatedAt : createdAt);
    return isEdited == true ? 'Edited · $time' : time;
  }
}
