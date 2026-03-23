import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/history_record.dart';
import '../../bulletin/presentation/widgets/bulletin_item_model.dart';

/// 历史记录存储服务
class HistoryStorageService {
  static const String _historyKey = 'history_records';
  static bool _isInitialized = false;
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    if (_isInitialized && _prefs != null) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('History SharedPreferences initialized');
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      _isInitialized = false;
    }
  }

  /// 保存历史记录
  static Future<bool> saveHistory(HistoryRecord record) async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, cannot save history');
        return false;
      }

      final histories = await getAllHistories();

      // 检查是否已存在相同日期的记录
      final existingIndex = histories.indexWhere((h) =>
        h.date.year == record.date.year &&
        h.date.month == record.date.month &&
        h.date.day == record.date.day
      );

      if (existingIndex != -1) {
        // 更新现有记录
        histories[existingIndex] = record;
      } else {
        // 添加新记录
        histories.add(record);
      }

      final jsonList = histories.map((h) => h.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final result = await _prefs!.setString(_historyKey, jsonString);

      debugPrint('Saved history record for ${record.date}');
      return result;
    } catch (e) {
      debugPrint('Error saving history: $e');
      return false;
    }
  }

  /// 获取所有历史记录（按日期降序排列）
  static Future<List<HistoryRecord>> getAllHistories() async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, returning empty history');
        return [];
      }

      final jsonString = _prefs!.getString(_historyKey);

      if (jsonString == null) {
        debugPrint('No history found in local storage');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final histories = jsonList
          .map((json) => HistoryRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      // 按日期降序排列
      histories.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Loaded ${histories.length} history records');
      return histories;
    } catch (e) {
      debugPrint('Error loading histories: $e');
      return [];
    }
  }

  /// 根据日期获取历史记录
  static Future<HistoryRecord?> getHistoryByDate(DateTime date) async {
    final histories = await getAllHistories();

    for (var history in histories) {
      if (history.date.year == date.year &&
          history.date.month == date.month &&
          history.date.day == date.day) {
        return history;
      }
    }

    return null;
  }

  /// 删除历史记录
  static Future<bool> deleteHistory(String id) async {
    try {
      final histories = await getAllHistories();
      final initialLength = histories.length;
      histories.removeWhere((h) => h.id == id);

      if (histories.length == initialLength) {
        return false;
      }

      final jsonList = histories.map((h) => h.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final result = await _prefs!.setString(_historyKey, jsonString);

      debugPrint('Deleted history record: $id');
      return result;
    } catch (e) {
      debugPrint('Error deleting history: $e');
      return false;
    }
  }

  /// 清空所有历史记录
  static Future<bool> clearAllHistories() async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, cannot clear history');
        return false;
      }

      final result = await _prefs!.remove(_historyKey);
      debugPrint('Cleared all history records');
      return result;
    } catch (e) {
      debugPrint('Error clearing histories: $e');
      return false;
    }
  }

  /// 从公告列表创建历史记录
  static HistoryRecord createHistoryRecord({
    required DateTime date,
    required int sabbathNumber,
    required List<BulletinItem> bulletins,
  }) {
    final now = DateTime.now();
    return HistoryRecord(
      id: 'history_${date.millisecondsSinceEpoch}',
      date: date,
      sabbathNumber: sabbathNumber,
      bulletins: bulletins,
      createdAt: now,
      updatedAt: now,
    );
  }
}
