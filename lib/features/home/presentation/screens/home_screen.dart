import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../../core/services/sunset_service.dart';
import '../../../../core/services/sabbath_calculator.dart';
import '../../../sabbath/data/sabbath_info_service.dart';
import '../../../sabbath/domain/models/sabbath_service.dart';
import '../../../../core/services/bulletin_storage_service.dart';
import '../../../bulletin/data/bulletin_data.dart';
import '../../../bulletin/presentation/widgets/bulletin_item_model.dart';

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
  late List<SabbathService> _fridayServices;
  late List<SabbathService> _saturdayServices;
  List<BulletinItem> _fridayBulletins = [];
  List<BulletinItem> _saturdayBulletins = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSunsetTimes();
    _loadSabbathServices();
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
      setState(() {});
    }
  }

  void _loadSunsetTimes() {
    _fridaySunset = SunsetService.getThisFridaySunset();
    _saturdaySunset = SunsetService.getThisSaturdaySunset();
    _updateSabbathMessage();
  }

  void _loadSabbathServices() {
    _fridayServices = SabbathInfoService.getFridayServices();
    _saturdayServices = SabbathInfoService.getSaturdayServices();
  }

  void _loadBulletins() async {
    // 先从本地存储加载最新的数据
    try {
      final loadedBulletins = await BulletinStorageService.loadBulletins();
      if (loadedBulletins.isNotEmpty) {
        bulletinItems = loadedBulletins;
      }
    } catch (e) {
      debugPrint('Failed to load bulletins: $e');
    }

    // 过滤出周五和周六的公告
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    // 计算本周五和本周六的日期
    int daysUntilFriday = (5 - currentWeekday + 7) % 7;
    int daysUntilSaturday = (6 - currentWeekday + 7) % 7;

    DateTime fridayDate = now.add(Duration(days: daysUntilFriday == 0 ? 0 : daysUntilFriday));
    DateTime saturdayDate = now.add(Duration(days: daysUntilSaturday == 0 ? 0 : daysUntilSaturday));

    // 检查每个公告的 publishDate 是否在周五或周六
    _fridayBulletins = bulletinItems.where((item) {
      final itemDate = DateTime(item.publishDate.year, item.publishDate.month, item.publishDate.day);
      final targetDate = DateTime(fridayDate.year, fridayDate.month, fridayDate.day);
      return itemDate.isAtSameMomentAs(targetDate);
    }).toList();

    _saturdayBulletins = bulletinItems.where((item) {
      final itemDate = DateTime(item.publishDate.year, item.publishDate.month, item.publishDate.day);
      final targetDate = DateTime(saturdayDate.year, saturdayDate.month, saturdayDate.day);
      return itemDate.isAtSameMomentAs(targetDate);
    }).toList();

    if (mounted) {
      setState(() {});
    }
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
    final guestName = context.watch<UserProvider>().guestName;
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await context.push('/home/bulletin/edit', extra: {
                  'dayOfWeek': _tabController.index == 0 ? 5 : 6, // 0 = Friday (5), 1 = Saturday (6)
                });
                // 从编辑页面返回后，重新加载数据
                if (result != null || mounted) {
                  _loadBulletins();
                }
              },
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
                user != null
                    ? 'Welcome, ${user.username}'
                    : guestName != null
                        ? 'Welcome, $guestName'
                        : 'Welcome, Guest',
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
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () => context.push('/admin/manage-users'),
                  tooltip: 'Manage Users',
                ),
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
                          // 日期和安息日编号
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  SabbathCalculator.getCurrentDateText(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  SabbathCalculator.getCurrentSabbathText(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
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
                ],
              ),
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
                          duration: const Duration(milliseconds: 250),
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
                                      offset: const Offset(-2, -2),
                                      blurRadius: 4,
                                    ),
                                    // 右下: 深色阴影
                                    BoxShadow(
                                      color: const Color(0xFFB6B9BA),
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
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
                          duration: const Duration(milliseconds: 250),
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
                                      offset: const Offset(-2, -2),
                                      blurRadius: 4,
                                    ),
                                    // 右下: 深色阴影
                                    BoxShadow(
                                      color: const Color(0xFFB6B9BA),
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
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
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Friday Evening 内容
                  _buildScheduleContent(theme, _fridayServices, _fridayBulletins, isAdmin),
                  // Sabbath 内容
                  _buildScheduleContent(theme, _saturdayServices, _saturdayBulletins, isAdmin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(
    ThemeData theme,
    List<SabbathService> services,
    List<BulletinItem> bulletins,
    bool isAdmin,
  ) {
    // 优先显示用户添加的 bulletins
    if (bulletins.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bulletins.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildBulletinCard(theme, bulletins[index], isAdmin);
        },
      );
    }

    // 否则显示默认的 SabbathService
    if (services.isEmpty) {
      return SizedBox(
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
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildSabbathServiceCard(theme, services[index]);
      },
    );
  }

  Widget _buildBulletinCard(ThemeData theme, BulletinItem bulletin, bool isAdmin) {
    return Container(
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
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              bulletin.icon,
              size: 24,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bulletin.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => context.push('/home/bulletin/edit', extra: {
                          'item': bulletin,
                        }),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  bulletin.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                if (bulletin.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bulletin.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
                if (bulletin.servicePersonnel != null && bulletin.servicePersonnel!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bulletin.servicePersonnel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSabbathServiceCard(ThemeData theme, SabbathService service) {
    return Container(
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
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              service.time,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                if (service.description != null && service.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
                if (service.personnel != null && service.personnel!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.personnel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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

}