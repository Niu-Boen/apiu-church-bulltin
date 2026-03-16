import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../data/bulletin_data.dart';
import '../widgets/bulletin_item_model.dart';

class BulletinScreen extends StatefulWidget {
  const BulletinScreen({super.key});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Bulletin'),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.primaryColor.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Friday Evening'),
            Tab(text: 'Sabbath Morning'),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () =>
                  context.push('/edit-bulletin', extra: {'refresh': _refresh}),
              child: const Icon(Icons.add),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimeline(context, 'Friday', isAdmin),
          _buildTimeline(context, 'Saturday', isAdmin),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, String day, bool isAdmin) {
    final items = bulletinItems.where((item) {
      return item.time.contains(day) ||
          (day == 'Saturday' && !item.time.contains('Friday'));
    }).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No programs scheduled.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        // 模拟刷新
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: isAdmin
                ? () => context.push('/edit-bulletin',
                    extra: {'item': item, 'refresh': _refresh})
                : null,
            borderRadius: BorderRadius.circular(16),
            child: _buildTimelineItem(context, item, index == items.length - 1),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, BulletinItem item, bool isLast) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间轴列
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 内容卡片
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.time,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                    if (item.servicePersonnel != null &&
                        item.servicePersonnel!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPersonnelChip(context, item.servicePersonnel!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonnelChip(BuildContext context, String personnel) {
    final theme = Theme.of(context);
    final colonIndex = personnel.indexOf(':');
    final role = colonIndex != -1
        ? personnel.substring(0, colonIndex).trim()
        : 'Service';
    final name = colonIndex != -1
        ? personnel.substring(colonIndex + 1).trim()
        : personnel;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
