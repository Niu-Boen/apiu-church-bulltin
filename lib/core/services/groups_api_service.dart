import '../../core/services/api_service.dart';

/// Groups API 服务
class GroupsApiService {
  static final GroupsApiService _instance = GroupsApiService._internal();
  factory GroupsApiService() => _instance;
  GroupsApiService._internal();

  final _api = ApiService();

  /// 获取所有小组
  Future<Map<String, dynamic>> listGroups({
    int? skip,
    int? limit,
  }) async {
    final response = await _api.get('/groups', queryParameters: {
      if (skip != null) 'skip': skip,
      if (limit != null) 'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 创建小组
  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> data) async {
    final response = await _api.post('/groups', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取单个小组
  Future<Map<String, dynamic>> getGroup(String groupId) async {
    final response = await _api.get('/groups/$groupId');
    return response.data as Map<String, dynamic>;
  }

  /// 更新小组
  Future<Map<String, dynamic>> updateGroup(
      String groupId, Map<String, dynamic> data) async {
    final response = await _api.put('/groups/$groupId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除小组
  Future<void> deleteGroup(String groupId) async {
    await _api.delete('/groups/$groupId');
  }
}
