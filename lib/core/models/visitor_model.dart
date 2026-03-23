/// 访客数据模型
class VisitorModel {
  final String id;
  final String name;
  final int visitCount;
  final DateTime firstVisitDate;
  final DateTime? lastVisitDate;

  VisitorModel({
    required this.id,
    required this.name,
    required this.visitCount,
    required this.firstVisitDate,
    this.lastVisitDate,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      visitCount: json['visitCount'] as int,
      firstVisitDate: DateTime.parse(json['firstVisitDate'] as String),
      lastVisitDate: json['lastVisitDate'] != null
          ? DateTime.parse(json['lastVisitDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'visitCount': visitCount,
      'firstVisitDate': firstVisitDate.toIso8601String(),
      'lastVisitDate': lastVisitDate?.toIso8601String(),
    };
  }

  VisitorModel copyWith({
    String? id,
    String? name,
    int? visitCount,
    DateTime? firstVisitDate,
    DateTime? lastVisitDate,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      visitCount: visitCount ?? this.visitCount,
      firstVisitDate: firstVisitDate ?? this.firstVisitDate,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
    );
  }
}
