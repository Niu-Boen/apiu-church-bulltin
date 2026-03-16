class SabbathService {
  final String id;
  final String day; // 'friday' 或 'saturday'
  final String time;
  final String title;
  final String? description;
  final String? personnel; // 服侍人员姓名/角色
  final int order; // 排序

  SabbathService({
    required this.id,
    required this.day,
    required this.time,
    required this.title,
    this.description,
    this.personnel,
    required this.order,
  });
}
