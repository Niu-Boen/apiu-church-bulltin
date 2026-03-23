import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/bulletin/presentation/widgets/bulletin_item_model.dart';

/// 公告本地存储服务
/// 用于持久化 bulletin 数据
class BulletinStorageService {
  static const String _bulletinsKey = 'bulletin_items';
  static bool _isInitialized = false;
  static SharedPreferences? _prefs;

  /// 初始化 SharedPreferences（在 Windows 平台上需要）
  static Future<void> _initPrefs() async {
    if (_isInitialized && _prefs != null) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('SharedPreferences initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      _isInitialized = false;
    }
  }

  /// 保存所有 bulletin 条目
  static Future<bool> saveBulletins(List<BulletinItem> bulletins) async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, cannot save');
        return false;
      }

      final jsonList = bulletins.map((item) => _itemToJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      final result = await _prefs!.setString(_bulletinsKey, jsonString);
      debugPrint('Saved ${bulletins.length} bulletins to local storage');
      return result;
    } catch (e) {
      debugPrint('Error saving bulletins: $e');
      return false;
    }
  }

  /// 加载所有 bulletin 条目
  static Future<List<BulletinItem>> loadBulletins() async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, returning empty list');
        return [];
      }

      final jsonString = _prefs!.getString(_bulletinsKey);

      if (jsonString == null) {
        debugPrint('No bulletins found in local storage');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final bulletins = jsonList
          .map((json) => _itemFromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Loaded ${bulletins.length} bulletins from local storage');
      return bulletins;
    } catch (e) {
      debugPrint('Error loading bulletins: $e');
      return [];
    }
  }

  /// 添加单个 bulletin 条目（最多保存20条）
  static Future<bool> addBulletin(BulletinItem item) async {
    try {
      final bulletins = await loadBulletins();

      // 检查是否已存在相同的条目（根据标题和时间判断）
      final existingIndex = bulletins.indexWhere(
        (b) => b.title == item.title && b.time == item.time,
      );

      if (existingIndex != -1) {
        // 如果已存在，更新该条目
        bulletins[existingIndex] = item;
      } else {
        // 添加新条目
        bulletins.add(item);

        // 限制最多保存20条记录
        if (bulletins.length > 20) {
          // 按发布时间排序，删除最旧的
          bulletins.sort((a, b) => a.publishDate.compareTo(b.publishDate));
          final excessCount = bulletins.length - 20;
          // 删除多余的条目（保留最新的20条）
          bulletins.removeRange(0, excessCount);
        }
      }

      return await saveBulletins(bulletins);
    } catch (e) {
      debugPrint('Error adding bulletin: $e');
      return false;
    }
  }

  /// 更新 bulletin 条目
  static Future<bool> updateBulletin(BulletinItem oldItem, BulletinItem newItem) async {
    try {
      final bulletins = await loadBulletins();

      // 尝试通过多个字段匹配找到条目
      final index = bulletins.indexWhere((item) =>
        item.title == oldItem.title &&
        item.time == oldItem.time &&
        item.description == oldItem.description
      );

      if (index != -1) {
        bulletins[index] = newItem;
        return await saveBulletins(bulletins);
      }
      return false;
    } catch (e) {
      debugPrint('Error updating bulletin: $e');
      return false;
    }
  }

  /// 删除 bulletin 条目
  static Future<bool> deleteBulletin(BulletinItem item) async {
    try {
      final bulletins = await loadBulletins();
      final result = bulletins.remove(item);
      if (result) {
        return await saveBulletins(bulletins);
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting bulletin: $e');
      return false;
    }
  }

  /// 清空所有 bulletins
  static Future<bool> clearBulletins() async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, cannot clear');
        return false;
      }

      final result = await _prefs!.remove(_bulletinsKey);
      debugPrint('Cleared all bulletins from local storage');
      return result;
    } catch (e) {
      debugPrint('Error clearing bulletins: $e');
      return false;
    }
  }

  /// 将 BulletinItem 转换为 JSON
  static Map<String, dynamic> _itemToJson(BulletinItem item) {
    return {
      'title': item.title,
      'time': item.time,
      'description': item.description,
      'servicePersonnel': item.servicePersonnel,
      'iconCodepoint': item.icon.codePoint,
      'iconFontFamily': item.icon.fontFamily,
      'publishDate': item.publishDate.toIso8601String(),
      'isDraft': item.isDraft,
      'scheduledDate': item.scheduledDate?.toIso8601String(),
    };
  }

  /// 从 JSON 创建 BulletinItem
  static BulletinItem _itemFromJson(Map<String, dynamic> json) {
    return BulletinItem(
      title: json['title'] as String,
      time: json['time'] as String,
      description: json['description'] as String,
      servicePersonnel: json['servicePersonnel'] as String?,
      icon: IconData(
        json['iconCodepoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
      ),
      publishDate: DateTime.parse(json['publishDate'] as String),
      isDraft: json['isDraft'] as bool? ?? false,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
    );
  }
}
