import '../../core/services/api_service.dart';

/// Members API 服务
class MembersApiService {
  static final MembersApiService _instance = MembersApiService._internal();
  factory MembersApiService() => _instance;
  MembersApiService._internal();

  final _api = ApiService();

  /// 获取所有成员
  Future<Map<String, dynamic>> listMembers({
    int? skip,
    int? limit,
  }) async {
    final response = await _api.get('/members', queryParameters: {
      if (skip != null) 'skip': skip,
      if (limit != null) 'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 创建成员
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> data) async {
    final response = await _api.post('/members', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取单个成员
  Future<Map<String, dynamic>> getMember(String memberId) async {
    final response = await _api.get('/members/$memberId');
    return response.data as Map<String, dynamic>;
  }

  /// 更新成员
  Future<Map<String, dynamic>> updateMember(
      String memberId, Map<String, dynamic> data) async {
    final response = await _api.put('/members/$memberId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除成员
  Future<void> deleteMember(String memberId) async {
    await _api.delete('/members/$memberId');
  }

  /// 获取成员历史记录
  Future<Map<String, dynamic>> getMemberHistory(String memberId) async {
    final response = await _api.get('/members/$memberId/history');
    return response.data as Map<String, dynamic>;
  }
}
