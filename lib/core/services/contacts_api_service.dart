import '../../core/services/api_service.dart';

/// Contacts API 服务
class ContactsApiService {
  static final ContactsApiService _instance = ContactsApiService._internal();
  factory ContactsApiService() => _instance;
  ContactsApiService._internal();

  final _api = ApiService();

  /// 获取所有联系人
  Future<Map<String, dynamic>> listContacts({
    int? skip,
    int? limit,
  }) async {
    final response = await _api.get('/contacts', queryParameters: {
      if (skip != null) 'skip': skip,
      if (limit != null) 'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 创建联系人
  Future<Map<String, dynamic>> createContact(Map<String, dynamic> data) async {
    final response = await _api.post('/contacts', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取单个联系人
  Future<Map<String, dynamic>> getContact(String contactId) async {
    final response = await _api.get('/contacts/$contactId');
    return response.data as Map<String, dynamic>;
  }

  /// 更新联系人
  Future<Map<String, dynamic>> updateContact(
      String contactId, Map<String, dynamic> data) async {
    final response = await _api.put('/contacts/$contactId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除联系人
  Future<void> deleteContact(String contactId) async {
    await _api.delete('/contacts/$contactId');
  }
}
