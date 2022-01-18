import 'package:intl/intl.dart';

class ConversationsUtil {
  static String parseDateTime(DateTime timestamp,
      {String format = 'MMM d, h:mm a'}) {
    final dateTime = timestamp.toLocal();
    return DateFormat(format).format(dateTime).toString();
  }
}
