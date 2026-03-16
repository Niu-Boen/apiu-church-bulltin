import 'package:flutter/material.dart';
import '../../data/bulletin_data.dart';
import '../widgets/bulletin_item_model.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 过滤出已发布的非草稿条目
    final publishedItems = bulletinItems.where((item) => !item.isDraft).toList();
    // 按日期分组
    final Map<DateTime, List<BulletinItem>> grouped = {};
    for (var item in publishedItems) {
      final date = DateTime(item.publishDate.year, item.publishDate.month, item.publishDate.day);
      grouped.putIfAbsent(date, () => []).add(item);
    }
    // 按日期倒序排序
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Historical Bulletins')),
      body: ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final items = grouped[date]!;
          return ExpansionTile(
            title: Text('${date.year}-${date.month}-${date.day}'),
            children: items.map((item) => ListTile(
              title: Text(item.title),
              subtitle: Text(item.time),
            )).toList(),
          );
        },
      ),
    );
  }
}