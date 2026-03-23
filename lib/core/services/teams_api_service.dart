import '../../core/services/api_service.dart';

/// Teams API 服务
class TeamsApiService {
  static final TeamsApiService _instance = TeamsApiService._internal();
  factory TeamsApiService() => _instance;
  TeamsApiService._internal();

  final _api = ApiService();

  /// 获取所有团队
  Future<Map<String, dynamic>> listTeams({
    int? skip,
    int? limit,
  }) async {
    final response = await _api.get('/teams', queryParameters: {
      if (skip != null) 'skip': skip,
      if (limit != null) 'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 创建团队
  Future<Map<String, dynamic>> createTeam(Map<String, dynamic> data) async {
    final response = await _api.post('/teams', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取单个团队
  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final response = await _api.get('/teams/$teamId');
    return response.data as Map<String, dynamic>;
  }

  /// 更新团队
  Future<Map<String, dynamic>> updateTeam(
      String teamId, Map<String, dynamic> data) async {
    final response = await _api.put('/teams/$teamId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除团队
  Future<void> deleteTeam(String teamId) async {
    await _api.delete('/teams/$teamId');
  }
}
