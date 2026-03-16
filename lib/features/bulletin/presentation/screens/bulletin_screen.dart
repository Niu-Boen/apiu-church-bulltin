import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bulletin_item_model.dart';
import '../../data/bulletin_data.dart';

class BulletinScreen extends StatefulWidget {
  final bool isAdmin;
  const BulletinScreen({super.key, this.isAdmin = false});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worship Schedule'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: () => context.go('/edit-bulletin', extra: {'refresh': _refresh}),
            ),
        ],
      ),
      body: bulletinItems.isEmpty
          ? _buildEmptyState(theme)
          : Stack(
              children: [
                // 3A. Timeline Line
                Positioned(
                  left: 27,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: theme.primaryColor,
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  itemCount: bulletinItems.length,
                  itemBuilder: (context, index) {
                    return _buildTimelineItem(context, bulletinItems[index], theme);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        'No events scheduled yet.',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, BulletinItem item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3C. Timeline Node
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 4, right: 20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryColor, width: 2),
            ),
          ),
          // Event Content Card
          Expanded(
            child: InkWell(
              onTap: widget.isAdmin
                  ? () => context.go('/edit-bulletin', extra: {'item': item, 'refresh': _refresh})
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                          ),
                          Text(
                            item.time,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item.description, style: theme.textTheme.bodyMedium),
                      if (item.servicePersonnel != null && item.servicePersonnel!.isNotEmpty) ...[
                        const Divider(height: 24),
                        // 3D. Personnel & Role Grid
                        _buildPersonnelGrid(item.servicePersonnel!, theme),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonnelGrid(String personnelText, ThemeData theme) {
    // Basic parser for "Role: Name" format
    final parts = personnelText.split(':');
    final role = parts.length > 1 ? parts[0].trim().toLowerCase() : 'personnel';
    final name = parts.length > 1 ? parts[1].trim() : parts[0].trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}
