import 'package:flutter/material.dart';

/// 代表一个礼拜公告条目的数据模型
class BulletinItem {
  final String title;
  final String time;
  final String description;
  final String? servicePersonnel;
  final IconData icon;
  final DateTime publishDate;      // 发布日期（用于归档）
  final bool isDraft;              // 是否为草稿
  final DateTime? scheduledDate;   // 定时发布日期

  BulletinItem({
    required this.title,
    required this.time,
    required this.description,
    this.servicePersonnel,
    required this.icon,
    required this.publishDate,
    this.isDraft = false,
    this.scheduledDate,
  });
}