import '../../core/services/api_service.dart';

/// Calendar API 服务
class CalendarApiService {
  static final CalendarApiService _instance = CalendarApiService._internal();
  factory CalendarApiService() => _instance;
  CalendarApiService._internal();

  final _api = ApiService();

  /// 获取所有日历事件
  Future<Map<String, dynamic>> listCalendarEvents({
    int? skip,
    int? limit,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _api.get('/calendar', queryParameters: {
      if (skip != null) 'skip': skip,
      if (limit != null) 'limit': limit,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 创建日历事件
  Future<Map<String, dynamic>> createCalendarEvent(
      Map<String, dynamic> data) async {
    final response = await _api.post('/calendar', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取单个日历事件
  Future<Map<String, dynamic>> getCalendarEvent(String eventId) async {
    final response = await _api.get('/calendar/$eventId');
    return response.data as Map<String, dynamic>;
  }

  /// 更新日历事件
  Future<Map<String, dynamic>> updateCalendarEvent(
      String eventId, Map<String, dynamic> data) async {
    final response = await _api.put('/calendar/$eventId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除日历事件
  Future<void> deleteCalendarEvent(String eventId) async {
    await _api.delete('/calendar/$eventId');
  }
}
