import '../../bulletin/presentation/widgets/bulletin_item_model.dart';

/// 历史记录数据模型
/// 用于存储某个日期的公告和时间表
class HistoryRecord {
  final String id;
  final DateTime date;
  final int sabbathNumber;
  final List<BulletinItem> bulletins;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryRecord({
    required this.id,
    required this.date,
    required this.sabbathNumber,
    required this.bulletins,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'sabbathNumber': sabbathNumber,
      'bulletins': bulletins.map((b) => _bulletinToJson(b)).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      sabbathNumber: json['sabbathNumber'] as int,
      bulletins: (json['bulletins'] as List)
          .map((b) => _bulletinFromJson(b as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> _bulletinToJson(BulletinItem item) {
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

  static BulletinItem _bulletinFromJson(Map<String, dynamic> json) {
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
