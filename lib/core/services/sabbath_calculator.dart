/// 安息日计算服务
class SabbathCalculator {
  /// 获取指定日期是一年中的第几个安息日
  static int getSabbathOfYear(DateTime date) {
    // 找到该日期所在周的周六（安息日从周五日落到周六日落）
    DateTime saturday = _getSaturdayOf(date);

    // 找到该年的第一个安息日
    DateTime firstSabbath = _getFirstSabbathOfYear(saturday.year);

    // 计算周数差
    int daysDifference = saturday.difference(firstSabbath).inDays;
    int sabbathCount = (daysDifference / 7).floor() + 1;

    return sabbathCount;
  }

  /// 获取指定日期所在周的周六
  static DateTime _getSaturdayOf(DateTime date) {
    int dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
    int daysUntilSaturday = (6 - dayOfWeek + 7) % 7;
    return date.add(Duration(days: daysUntilSaturday));
  }

  /// 获取指定年份的第一个安息日
  static DateTime _getFirstSabbathOfYear(int year) {
    DateTime january1 = DateTime(year, 1, 1);
    return _getSaturdayOf(january1);
  }

  /// 获取当前日期是今年第几个安息日
  static int getCurrentSabbathOfYear() {
    return getSabbathOfYear(DateTime.now());
  }

  /// 获取安息日的格式化文本
  static String getSabbathText(DateTime date) {
    int sabbathNumber = getSabbathOfYear(date);
    return 'Sabbath #$sabbathNumber of the Year';
  }

  /// 获取当前安息日的格式化文本
  static String getCurrentSabbathText() {
    return getSabbathText(DateTime.now());
  }

  /// 获取日期格式化文本
  static String getDateText(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  /// 获取当前日期格式化文本
  static String getCurrentDateText() {
    return getDateText(DateTime.now());
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
