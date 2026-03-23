import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../../core/services/sunset_service.dart';
import '../../../bulletin/data/bulletin_data.dart';
import '../../../bulletin/presentation/widgets/bulletin_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _fridaySunset;
  late DateTime _saturdaySunset;
  late String _sabbathMessage;
  late Color _messageColor;
  List<BulletinItem> _filteredBulletins = [];
  bool _isLoadingBulletins = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSunsetTimes();
    _loadBulletins();
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        _filterBulletins();
      });
    }
  }

  void _loadSunsetTimes() {
    _fridaySunset = SunsetService.getThisFridaySunset();
    _saturdaySunset = SunsetService.getThisSaturdaySunset();
    _updateSabbathMessage();
  }

  void _updateSabbathMessage() {
    final now = DateTime.now();
    final oneHourBeforeFriday = _fridaySunset.subtract(const Duration(hours: 1));

    if (now.isAfter(_fridaySunset) && now.isBefore(_saturdaySunset)) {
      _sabbathMessage = '✨ Shabbat Shalom! ✨';
      _messageColor = Colors.purple;
    } else if (now.isAfter(oneHourBeforeFriday) && now.isBefore(_fridaySunset)) {
      _sabbathMessage = '🕯️ Sabbath is coming soon 🕯️';
      _messageColor = Colors.orange;
    } else if (now.isBefore(_fridaySunset)) {
      final difference = _fridaySunset.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      if (days > 0) {
        _sabbathMessage = 'Next Sabbath in $days days $hours hours';
      } else {
        _sabbathMessage = 'Next Sabbath in $hours hours';
      }
      _messageColor = Colors.blue;
    } else {
      final nextFriday = _fridaySunset.add(const Duration(days: 7));
      final difference = nextFriday.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      _sabbathMessage = 'Next Sabbath in $days days $hours hours';
      _messageColor = Colors.grey;
    }
  }

  void _loadBulletins() async {
    setState(() {
      _isLoadingBulletins = true;
    });

    try {
      // 从本地存储重新加载数据
      final prefs = await SharedPreferences.getInstance();
      final bulletinsKey = 'bulletin_items';
      final jsonString = prefs.getString(bulletinsKey);

      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        final bulletins = jsonList.map((json) {
          final item = json as Map<String, dynamic>;
          return BulletinItem(
            title: item['title'] as String,
            time: item['time'] as String,
            description: item['description'] as String,
            servicePersonnel: item['servicePersonnel'] as String?,
            icon: IconData(
              item['iconCodepoint'] as int,
              fontFamily: item['iconFontFamily'] as String?,
            ),
            publishDate: DateTime.parse(item['publishDate'] as String),
            isDraft: item['isDraft'] as bool? ?? false,
            scheduledDate: item['scheduledDate'] != null
                ? DateTime.parse(item['scheduledDate'] as String)
                : null,
          );
        }).toList();

        // 更新全局列表
        bulletinItems.clear();
        bulletinItems.addAll(bulletins);

        _filterBulletins();
      } else {
        _filterBulletins();
      }
    } catch (e) {
      debugPrint('Error loading bulletins: $e');
      _filterBulletins();
    }

    setState(() {
      _isLoadingBulletins = false;
    });
  }

  void _filterBulletins() {
    final tabIndex = _tabController.index;
    // 0 = Friday, 1 = Saturday
    final targetDay = tabIndex == 0 ? 'Friday' : 'Saturday';
    final targetDayOfWeek = targetDay == 'Friday' ? 5 : 6;

    _filteredBulletins = bulletinItems.where((item) {
      final itemDay = item.publishDate.weekday;
      return itemDay == targetDayOfWeek || item.time.toLowerCase().contains(targetDay.toLowerCase());
    }).toList();
  }

  Future<void> _logout() async {
    if (!mounted) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<UserProvider>().logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().currentUser;
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => context.push('/home/bulletin/edit', extra: {
                'refresh': _loadBulletins,
                'dayOfWeek': _tabController.index == 0 ? 5 : 6, // 0 = Friday (5), 1 = Saturday (6)
              }),
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                user != null ? 'Welcome, ${user.username}' : 'Welcome, Guest',
                style: const TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.church_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 安息日卡片
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _messageColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _sabbathMessage,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: _messageColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSunsetInfo(
                                  context,
                                  label: 'Friday Sunset',
                                  time: _fridaySunset,
                                  icon: Icons.wb_twilight_rounded,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                              Expanded(
                                child: _buildSunsetInfo(
                                  context,
                                  label: 'Saturday Sunset',
                                  time: _saturdaySunset,
                                  icon: Icons.wb_sunny_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 经文卡片（以赛亚书58:13-14）
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verse of the Day',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '“If thou turn away thy foot from the sabbath, from doing thy pleasure on my holy day; and call the sabbath a delight, the holy of the LORD, honourable; and shalt honour him, not doing thine own ways, nor finding thine own pleasure, nor speaking thine own words: Then shalt thou delight thyself in the LORD; and I will cause thee to ride upon the high places of the earth, and feed thee with the heritage of Jacob thy father: for the mouth of the LORD hath spoken it. ”',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '— Isaiah 58:13-14',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bulletin 区域 - TabBar 和内容
                  _buildBulletinSection(theme, isAdmin),
                  const SizedBox(height: 16),

                  // 快速操作标题
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // 快速操作网格
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                _buildActionCard(
                  context,
                  icon: Icons.volunteer_activism,
                  title: 'Giving',
                  onTap: () => context.push('/giving'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.access_time,
                  title: 'Sabbath',
                  onTap: () => context.push('/sabbath'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.groups,
                  title: 'Volunteer',
                  onTap: () => context.push('/volunteer'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  onTap: () => context.push('/about'),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildBulletinSection(ThemeData theme, bool isAdmin) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TabBar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        final isSelected = _tabController.index == 0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            // 使用渐变背景色
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFB6B9BA),
                                      Color(0xFFF4F6F8),
                                    ],
                                    begin: FractionalOffset(0.5, 1.0),
                                    end: FractionalOffset(0.5, 0.0),
                                    stops: [0.0, 1.0],
                                  )
                                : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            // 使用新的阴影参数
                            boxShadow: isSelected
                                ? [
                                    // 左上: 浅色阴影
                                    BoxShadow(
                                      color: const Color(0xFFFAFAFD),
                                      offset: const Offset(-4, -4),
                                      blurRadius: 8,
                                    ),
                                    // 右下: 深色阴影
                                    BoxShadow(
                                      color: const Color(0xFFB6B9BA),
                                      offset: const Offset(4, 4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: InkWell(
                            onTap: () => _tabController.animateTo(0),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Friday Evening',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.primaryColor.withValues(alpha: 0.6),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        final isSelected = _tabController.index == 1;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            // 使用渐变背景色
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFB6B9BA),
                                      Color(0xFFF4F6F8),
                                    ],
                                    begin: FractionalOffset(0.5, 1.0),
                                    end: FractionalOffset(0.5, 0.0),
                                    stops: [0.0, 1.0],
                                  )
                                : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            // 使用新的阴影参数
                            boxShadow: isSelected
                                ? [
                                    // 左上: 浅色阴影
                                    BoxShadow(
                                      color: const Color(0xFFFAFAFD),
                                      offset: const Offset(-4, -4),
                                      blurRadius: 8,
                                    ),
                                    // 右下: 深色阴影
                                    BoxShadow(
                                      color: const Color(0xFFB6B9BA),
                                      offset: const Offset(4, 4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: InkWell(
                            onTap: () => _tabController.animateTo(1),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Sabbath',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.primaryColor.withValues(alpha: 0.6),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 内容区域
            _isLoadingBulletins
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredBulletins.isEmpty
                    ? SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: theme.disabledColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No programs scheduled for this day.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.disabledColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredBulletins.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildBulletinItemCard(theme, _filteredBulletins[index], isAdmin);
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletinItemCard(ThemeData theme, BulletinItem item, bool isAdmin) {
    return InkWell(
      onTap: isAdmin
          ? () => context.push('/home/bulletin/edit', extra: {
                'item': item,
                'refresh': _loadBulletins,
                'dayOfWeek': _tabController.index == 0 ? 5 : 6,
              })
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.servicePersonnel != null && item.servicePersonnel!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: theme.primaryColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.servicePersonnel!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunsetInfo(BuildContext context,
      {required String label, required DateTime time, required IconData icon}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          DateFormat('h:mm a').format(time),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}