import '../utils/date_parser.dart';

/// 程序项目模型
class ProgramItem {
  final String id;
  final String title;
  final String? description;
  final String? time;
  final String? servicePersonnel;
  final int order;
  final String? block;

  ProgramItem({
    required this.id,
    required this.title,
    this.description,
    this.time,
    this.servicePersonnel,
    this.order = 0,
    this.block,
  });

  factory ProgramItem.fromJson(Map<String, dynamic> json) {
    return ProgramItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      time: json['time'],
      servicePersonnel: json['service_personnel'] ?? json['servicePersonnel'],
      order: json['order'] ?? json['sequence'] ?? 0,
      block: json['block'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'service_personnel': servicePersonnel,
      'order': order,
      'block': block,
    };
  }
}

/// 协调员模型
class Coordinator {
  final String id;
  final String name;
  final String? role;

  Coordinator({
    required this.id,
    required this.name,
    this.role,
  });

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}

/// 公告通知模型
class Announcement {
  final String id;
  final String title;
  final String? content;
  final bool isPinned;
  final int order;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    this.content,
    this.isPinned = false,
    this.order = 0,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      isPinned: json['is_pinned'] ?? json['isPinned'] ?? false,
      order: json['order'] ?? 0,
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 主公告模型
class BulletinModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final List<ProgramItem> programs;
  final List<Coordinator> coordinators;
  final List<Announcement> announcements;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BulletinModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.programs = const [],
    this.coordinators = const [],
    this.announcements = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory BulletinModel.fromJson(Map<String, dynamic> json) {
    final programs = (json['programs'] as List<dynamic>?)
            ?.map((p) => ProgramItem.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    final coordinators = (json['coordinators'] as List<dynamic>?)
            ?.map((c) => Coordinator.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final announcements = (json['announcements'] as List<dynamic>?)
            ?.map((a) => Announcement.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    return BulletinModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: DateParser.parse(json['date']),
      programs: programs,
      coordinators: coordinators,
      announcements: announcements,
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateParser.parseNullable(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'programs': programs.map((p) => p.toJson()).toList(),
      'coordinators': coordinators.map((c) => c.toJson()).toList(),
      'announcements': announcements.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 获取格式化的日期字符串
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
