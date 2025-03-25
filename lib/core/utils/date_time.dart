import 'package:intl/intl.dart';

class DatetimeUtil {
  static String formatDateTimeFormat(DateTime dateTime) {
    String formattedDate = DateFormat('d MMMM, EEEE').format(dateTime);
    return formattedDate;
  }

  static String format(DateTime dateTime) {
    String formattedDate = DateFormat("yyyy-MM-dd'T'00:00:00").format(dateTime);
    return formattedDate;
  }

  static String formatCustom(DateTime? dateTime) {
    if (dateTime != null) {
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } else {
      DateTime now = DateTime.now(); // Lấy thời gian hiện tại
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(now);
    }
  }
}