import '../../../core/services/sunset_service.dart';
import '../domain/models/sabbath_service.dart';
import 'sabbath_data.dart';

class SabbathInfoService {
  /// 获取本周五和周六的日落时间（预设）
  static Map<String, DateTime> getThisWeekSunsetTimes() {
    return {
      'friday': SunsetService.getThisFridaySunset(),
      'saturday': SunsetService.getThisSaturdaySunset(),
    };
  }

  /// 获取周五的流程
  static List<SabbathService> getFridayServices() {
    return sabbathServices.where((s) => s.day == 'friday').toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取周六的流程
  static List<SabbathService> getSaturdayServices() {
    return sabbathServices.where((s) => s.day == 'saturday').toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 管理员更新流程（待实现持久化）
  static void updateServices(List<SabbathService> newServices) {
    sabbathServices.clear();
    sabbathServices.addAll(newServices);
  }
}
