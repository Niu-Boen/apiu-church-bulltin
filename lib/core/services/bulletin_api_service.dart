import '../../core/services/api_service.dart';

/// Bulletin API 服务
class BulletinApiService {
  static final BulletinApiService _instance = BulletinApiService._internal();
  factory BulletinApiService() => _instance;
  BulletinApiService._internal();

  final _api = ApiService();

  /// 获取所有公告
  Future<Map<String, dynamic>> listBulletins() async {
    final response = await _api.get('/bulletins');
    return response.data as Map<String, dynamic>;
  }

  /// 创建公告
  Future<Map<String, dynamic>> createBulletin(Map<String, dynamic> data) async {
    final response = await _api.post('/bulletins', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取单个公告
  Future<Map<String, dynamic>> getBulletin(String bulletinId) async {
    final response = await _api.get('/bulletins/$bulletinId');
    return response.data as Map<String, dynamic>;
  }

  /// 获取公告完整信息（包含programs, announcements, coordinators）
  Future<Map<String, dynamic>> getBulletinFull(String bulletinId) async {
    final response = await _api.get('/bulletins/$bulletinId/full');
    return response.data as Map<String, dynamic>;
  }

  /// 更新公告
  Future<Map<String, dynamic>> updateBulletin(
      String bulletinId, Map<String, dynamic> data) async {
    final response = await _api.put('/bulletins/$bulletinId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除公告
  Future<void> deleteBulletin(String bulletinId) async {
    await _api.delete('/bulletins/$bulletinId');
  }

  /// 获取公告的所有程序
  Future<Map<String, dynamic>> listPrograms(String bulletinId) async {
    final response = await _api.get('/bulletins/$bulletinId/programs');
    return response.data as Map<String, dynamic>;
  }

  /// 创建程序
  Future<Map<String, dynamic>> createProgram(
      String bulletinId, Map<String, dynamic> data) async {
    final response = await _api.post('/bulletins/$bulletinId/programs', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 更新程序
  Future<Map<String, dynamic>> updateProgram(
      String bulletinId, String itemId, Map<String, dynamic> data) async {
    final response =
        await _api.put('/bulletins/$bulletinId/programs/$itemId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除程序
  Future<void> deleteProgram(String bulletinId, String itemId) async {
    await _api.delete('/bulletins/$bulletinId/programs/$itemId');
  }

  /// 重新排序程序
  Future<void> reorderPrograms(
      String bulletinId, List<Map<String, dynamic>> items) async {
    await _api.patch('/bulletins/$bulletinId/programs/reorder', data: items);
  }

  /// 获取公告的协调员列表
  Future<Map<String, dynamic>> listCoordinators(String bulletinId) async {
    final response = await _api.get('/bulletins/$bulletinId/coordinators');
    return response.data as Map<String, dynamic>;
  }

  /// 更新/创建协调员
  Future<Map<String, dynamic>> upsertCoordinator(
      String bulletinId, String coordType, Map<String, dynamic> data) async {
    final response = await _api.put(
      '/bulletins/$bulletinId/coordinators/$coordType',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// 获取公告的所有公告/通知
  Future<Map<String, dynamic>> listAnnouncements(String bulletinId) async {
    final response = await _api.get('/bulletins/$bulletinId/announcements');
    return response.data as Map<String, dynamic>;
  }

  /// 创建公告/通知
  Future<Map<String, dynamic>> createAnnouncement(
      String bulletinId, Map<String, dynamic> data) async {
    final response = await _api.post('/bulletins/$bulletinId/announcements', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 更新公告/通知
  Future<Map<String, dynamic>> updateAnnouncement(
      String bulletinId, String annId, Map<String, dynamic> data) async {
    final response =
        await _api.put('/bulletins/$bulletinId/announcements/$annId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除公告/通知
  Future<void> deleteAnnouncement(String bulletinId, String annId) async {
    await _api.delete('/bulletins/$bulletinId/announcements/$annId');
  }
}
