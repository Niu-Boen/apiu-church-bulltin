import 'package:intl/intl.dart';

class SunsetService {
  /// 获取本周五的预设日落时间（默认18:45）
  static DateTime getThisFridaySunset() {
    final now = DateTime.now();
    // 找到本周五
    int daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    final fridayDate = now.add(Duration(days: daysUntilFriday));
    // 设置为当天18:45（可自定义）
    return DateTime(fridayDate.year, fridayDate.month, fridayDate.day, 18, 45);
  }

  /// 获取本周六的预设日落时间
  static DateTime getThisSaturdaySunset() {
    final friday = getThisFridaySunset();
    return friday.add(const Duration(days: 1));
  }

  /// 获取格式化的日落时间字符串
  static String getFormattedSunset(DateTime sunset) {
    return DateFormat('h:mm a').format(sunset);
  }
}
