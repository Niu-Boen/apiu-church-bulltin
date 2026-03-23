import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/visitor_model.dart';

/// 访客存储服务
class VisitorStorageService {
  static const String _visitorKey = 'visitor_records';
  static bool _isInitialized = false;
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    if (_isInitialized && _prefs != null) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('Visitor SharedPreferences initialized');
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      _isInitialized = false;
    }
  }

  /// 记录访客访问（首次访问创建记录，重复访问增加计数）
  static Future<VisitorModel?> recordVisitor(String name) async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, cannot record visitor');
        return null;
      }

      final visitors = await getAllVisitors();

      // 查找是否已存在同名访客
      VisitorModel? existingVisitor;
      for (var visitor in visitors) {
        if (visitor.name.toLowerCase() == name.toLowerCase()) {
          existingVisitor = visitor;
          break;
        }
      }

      VisitorModel updatedVisitor;

      if (existingVisitor != null) {
        // 更新现有访客记录
        updatedVisitor = existingVisitor.copyWith(
          visitCount: existingVisitor.visitCount + 1,
          lastVisitDate: DateTime.now(),
        );

        final index = visitors.indexOf(existingVisitor);
        visitors[index] = updatedVisitor;

        debugPrint('Updated visitor "${existingVisitor.name}" - visit count: ${updatedVisitor.visitCount}');
      } else {
        // 创建新访客记录
        final now = DateTime.now();
        updatedVisitor = VisitorModel(
          id: 'visitor_${now.millisecondsSinceEpoch}',
          name: name,
          visitCount: 1,
          firstVisitDate: now,
          lastVisitDate: now,
        );

        visitors.add(updatedVisitor);

        debugPrint('Created new visitor record: "$name"');
      }

      // 保存到本地存储
      final jsonList = visitors.map((v) => v.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs!.setString(_visitorKey, jsonString);

      return updatedVisitor;
    } catch (e) {
      debugPrint('Error recording visitor: $e');
      return null;
    }
  }

  /// 获取所有访客记录（按首次访问时间降序排列）
  static Future<List<VisitorModel>> getAllVisitors() async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, returning empty visitor list');
        return [];
      }

      final jsonString = _prefs!.getString(_visitorKey);

      if (jsonString == null) {
        debugPrint('No visitor records found');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final visitors = jsonList
          .map((json) => VisitorModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // 按首次访问时间降序排列
      visitors.sort((a, b) => b.firstVisitDate.compareTo(a.firstVisitDate));

      debugPrint('Loaded ${visitors.length} visitor records');
      return visitors;
    } catch (e) {
      debugPrint('Error loading visitors: $e');
      return [];
    }
  }

  /// 根据名称查找访客
  static Future<VisitorModel?> getVisitorByName(String name) async {
    final visitors = await getAllVisitors();

    for (var visitor in visitors) {
      if (visitor.name.toLowerCase() == name.toLowerCase()) {
        return visitor;
      }
    }

    return null;
  }

  /// 删除访客记录
  static Future<bool> deleteVisitor(String id) async {
    try {
      final visitors = await getAllVisitors();
      visitors.removeWhere((v) => v.id == id);

      final jsonList = visitors.map((v) => v.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final result = await _prefs!.setString(_visitorKey, jsonString);

      debugPrint('Deleted visitor record: $id');
      return result;
    } catch (e) {
      debugPrint('Error deleting visitor: $e');
      return false;
    }
  }

  /// 清空所有访客记录
  static Future<bool> clearAllVisitors() async {
    try {
      await _initPrefs();

      if (_prefs == null) {
        debugPrint('SharedPreferences not available, cannot clear visitors');
        return false;
      }

      final result = await _prefs!.remove(_visitorKey);
      debugPrint('Cleared all visitor records');
      return result;
    } catch (e) {
      debugPrint('Error clearing visitors: $e');
      return false;
    }
  }

  /// 获取访客总数
  static Future<int> getTotalVisitors() async {
    final visitors = await getAllVisitors();
    return visitors.length;
  }

  /// 获取总访问次数
  static Future<int> getTotalVisits() async {
    final visitors = await getAllVisitors();
    return visitors.fold<int>(0, (sum, visitor) => sum + visitor.visitCount);
  }
}
