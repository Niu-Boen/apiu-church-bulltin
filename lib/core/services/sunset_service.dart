import 'package:intl/intl.dart';

class SunsetService {
  /// 获取本周五的日落时间（东七区固定时间 18:15）
  static DateTime getThisFridaySunset() {
    final now = DateTime.now();
    // 找到本周五
    int daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    final fridayDate = now.add(Duration(days: daysUntilFriday));
    // 设置为当天18:15（东七区固定日落时间）
    return DateTime(fridayDate.year, fridayDate.month, fridayDate.day, 18, 15);
  }

  /// 获取本周六的日落时间（东七区固定时间 18:20）
  static DateTime getThisSaturdaySunset() {
    final friday = getThisFridaySunset();
    return friday.add(const Duration(days: 1, hours: 0, minutes: 5));
  }

  /// 获取格式化的日落时间字符串
  static String getFormattedSunset(DateTime sunset) {
    return DateFormat('h:mm a').format(sunset);
  }
}
