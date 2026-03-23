import '../presentation/widgets/bulletin_item_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/bulletin_storage_service.dart';

/// 存储所有公告条目的数据列表
/// 使用本地存储持久化数据
List<BulletinItem> bulletinItems = [];

/// 默认 bulletin 数据
final List<BulletinItem> _defaultBulletins = [
  BulletinItem(
    title: 'Sabbath School Lesson',
    time: '9:30 AM',
    description: 'Join us for a deep dive into this week\'s lesson study.',
    servicePersonnel: 'Leader: Elder John Doe',
    icon: Icons.book_online,
    publishDate: DateTime.now(),
  ),
  BulletinItem(
    title: 'Main Worship Service',
    time: '11:00 AM',
    description: 'Worship with us in the main sanctuary. All are welcome.',
    servicePersonnel: 'Speaker: Pr. Jane Smith',
    icon: Icons.church,
    publishDate: DateTime.now(),
  ),
  BulletinItem(
    title: 'Vespers Service',
    time: 'Friday 7:00 PM',
    description: 'Start the Sabbath with a blessed vespers service.',
    servicePersonnel: 'Coordinator: Sarah Johnson',
    icon: Icons.wb_sunny,
    publishDate: DateTime.now(),
  ),
  BulletinItem(
    title: 'Youth Program',
    time: '4:00 PM',
    description: 'Engaging activities and spiritual growth for the youth.',
    servicePersonnel: 'Leader: Mark Chen',
    icon: Icons.people,
    publishDate: DateTime.now(),
  ),
  BulletinItem(
    title: 'Community Outreach',
    time: 'Sunday 10:00 AM',
    description: 'Join us in serving the local community.',
    servicePersonnel: 'Organizer: Emily White',
    icon: Icons.group_work,
    publishDate: DateTime.now(),
  ),
];

/// 初始化 bulletin 数据
/// 从本地存储加载数据,如果没有则使用默认数据
Future<void> initializeBulletins() async {
  try {
    // 先使用默认数据，确保应用可以立即启动
    bulletinItems = List.from(_defaultBulletins);

    // 异步加载数据，不阻塞主线程
    final loadedBulletins = await BulletinStorageService.loadBulletins();

    if (loadedBulletins.isNotEmpty) {
      // 成功加载数据，使用加载的数据
      bulletinItems = loadedBulletins;
    }
  } catch (e) {
    debugPrint('Failed to load bulletins from storage: $e');
    // 加载失败，继续使用默认数据
  }
}

/// 保存当前 bulletins 到本地存储
Future<void> saveCurrentBulletins() async {
  try {
    await BulletinStorageService.saveBulletins(bulletinItems);
  } catch (e) {
    debugPrint('Error saving bulletins: $e');
  }
}