import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/bulletin_model.dart';

/// 公告API服务
class BulletinApiService {
  final ApiService _api = ApiService();

  /// 获取公告列表（分页）
  Future<Map<String, dynamic>> getBulletins({
    int page = 1,
    int pageSize = 10,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _api.get('/bulletins', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<BulletinModel> bulletins = (data['items'] as List<dynamic>?)
                ?.map((b) => BulletinModel.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [];

        return {
          'bulletins': bulletins,
          'total': data['total'] ?? 0,
          'page': data['page'] ?? page,
          'page_size': data['page_size'] ?? pageSize,
        };
      } else {
        throw Exception('Failed to fetch bulletins: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取单个公告详情（包含完整信息）
  Future<BulletinModel> getBulletinDetail(String id) async {
    try {
      final response = await _api.get('/bulletins/$id');

      if (response.statusCode == 200) {
        return BulletinModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch bulletin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 创建新公告
  Future<BulletinModel> createBulletin({
    required String title,
    String? description,
    required DateTime date,
    List<ProgramItem>? programs,
    List<Coordinator>? coordinators,
    List<Announcement>? announcements,
  }) async {
    try {
      final data = {
        'title': title,
        'date': date.toIso8601String(),
        if (description != null) 'description': description,
        if (programs != null) 'programs': programs.map((p) => p.toJson()).toList(),
        if (coordinators != null) 'coordinators': coordinators.map((c) => c.toJson()).toList(),
        if (announcements != null) 'announcements': announcements.map((a) => a.toJson()).toList(),
      };

      final response = await _api.post('/bulletins', data: data);

      if (response.statusCode == 201) {
        return BulletinModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create bulletin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 更新公告
  Future<BulletinModel> updateBulletin({
    required String id,
    String? title,
    String? description,
    DateTime? date,
    List<ProgramItem>? programs,
    List<Coordinator>? coordinators,
    List<Announcement>? announcements,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (date != null) data['date'] = date.toIso8601String();
      if (programs != null) data['programs'] = programs.map((p) => p.toJson()).toList();
      if (coordinators != null) data['coordinators'] = coordinators.map((c) => c.toJson()).toList();
      if (announcements != null) data['announcements'] = announcements.map((a) => a.toJson()).toList();

      final response = await _api.put('/bulletins/$id', data: data);

      if (response.statusCode == 200) {
        return BulletinModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update bulletin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 删除公告
  Future<void> deleteBulletin(String id) async {
    try {
      final response = await _api.delete('/bulletins/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete bulletin: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 添加程序项目
  Future<ProgramItem> addProgramItem({
    required String bulletinId,
    required String title,
    String? description,
    String? time,
    String? servicePersonnel,
    int? order,
    String? block,
  }) async {
    try {
      final data = {
        'title': title,
        if (description != null) 'description': description,
        if (time != null) 'time': time,
        if (servicePersonnel != null) 'service_personnel': servicePersonnel,
        if (order != null) 'order': order,
        if (block != null) 'block': block,
      };

      final response = await _api.post('/bulletins/$bulletinId/programs', data: data);

      if (response.statusCode == 201) {
        return ProgramItem.fromJson(response.data);
      } else {
        throw Exception('Failed to add program: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 添加公告通知
  Future<Announcement> addAnnouncement({
    required String bulletinId,
    required String title,
    String? content,
    bool? isPinned,
    int? order,
  }) async {
    try {
      final data = {
        'title': title,
        if (content != null) 'content': content,
        if (isPinned != null) 'is_pinned': isPinned,
        if (order != null) 'order': order,
      };

      final response = await _api.post('/bulletins/$bulletinId/announcements', data: data);

      if (response.statusCode == 201) {
        return Announcement.fromJson(response.data);
      } else {
        throw Exception('Failed to add announcement: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'An error occurred';
        return 'Error $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
