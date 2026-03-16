import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// 移除未使用的导入
// import '../widgets/bulletin_item_model.dart';
import '../../data/bulletin_data.dart';

class BulletinScreen extends StatefulWidget {
  final bool isAdmin;
  const BulletinScreen({super.key, this.isAdmin = false});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const double _tabBarHeight = 60.0;
  static const double _horizontalPadding = 16.0;
  static const double _verticalPadding = 8.0;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Bulletin'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(_tabBarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _verticalPadding,
            ),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Friday Evening'),
                  Tab(text: 'Sabbath Morning'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => context.go('/edit-bulletin', extra: {'refresh': _refresh}),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimeline(context, 'Friday'),
          _buildTimeline(context, 'Saturday'),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, String day) {
    final items = bulletinItems.where((item) {
      return item.time.contains(day) || (day == 'Saturday' && !item.time.contains('Friday'));
    }).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No programs scheduled.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return IntrinsicHeight(
          key: ValueKey('${item.time}_${item.title}'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Timeline Column ---
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: index == items.length - 1
                          ? Colors.transparent
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // --- Content Card ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    onTap: widget.isAdmin
                        ? () => context.go('/edit-bulletin', extra: {'item': item, 'refresh': _refresh})
                        : null,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.time,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            if (item.servicePersonnel != null && item.servicePersonnel!.isNotEmpty)
                              _buildPersonnelSection(context, item.servicePersonnel!),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonnelSection(BuildContext context, String personnel) {
    final int colonIndex = personnel.indexOf(':');
    String role, name;

    if (colonIndex != -1) {
      role = personnel.substring(0, colonIndex).trim();
      name = personnel.substring(colonIndex + 1).trim();
    } else {
      role = 'Service';
      name = personnel.trim();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}