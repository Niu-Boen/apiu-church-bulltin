import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 添加此行
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/user_provider.dart';
// ignore: unused_import
import '../../../sabbath/data/sabbath_info_service.dart';
import '../../../../core/services/sunset_service.dart';

// ... 其余代码保持不变（与之前提供的 home_screen.dart 相同）

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _fridaySunset;
  late DateTime _saturdaySunset;
  late String _sabbathMessage;
  late Color _messageColor;

  @override
  void initState() {
    super.initState();
    _loadSunsetTimes();
  }

  void _loadSunsetTimes() {
    // 获取预设的日落时间
    _fridaySunset = SunsetService.getThisFridaySunset();
    _saturdaySunset = SunsetService.getThisSaturdaySunset();
    _updateSabbathMessage();
  }

  void _updateSabbathMessage() {
    final now = DateTime.now();
    final oneHourBeforeFriday =
        _fridaySunset.subtract(const Duration(hours: 1));

    if (now.isAfter(_fridaySunset) && now.isBefore(_saturdaySunset)) {
      // 当前在安息日内
      _sabbathMessage = '✨ Shabbat Shalom! ✨';
      _messageColor = Colors.purple;
    } else if (now.isAfter(oneHourBeforeFriday) &&
        now.isBefore(_fridaySunset)) {
      // 安息日即将开始（1小时内）
      _sabbathMessage = '🕯️ Sabbath is coming soon 🕯️';
      _messageColor = Colors.orange;
    } else if (now.isBefore(_fridaySunset)) {
      // 距离周五日落还有时间
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
      // 安息日已过，计算到下一个周五
      final nextFriday = _fridaySunset.add(const Duration(days: 7));
      final difference = nextFriday.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      if (days > 0) {
        _sabbathMessage = 'Next Sabbath in $days days $hours hours';
      } else {
        _sabbathMessage = 'Next Sabbath in $hours hours';
      }
      _messageColor = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 安息日提醒卡片
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 动态提醒消息
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
                          // 日落时间
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

                  // 经文卡片
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
                            '"Let us not give up meeting together, as some are in the habit of doing, but encouraging one another—and all the more as you see the Day approaching."',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '— Hebrews 10:25',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 快速操作（可选，如果不需要可以删除）
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
          // 快速操作网格（保持原有）
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
                  icon: Icons.event,
                  title: 'Bulletin',
                  onTap: () => context.push('/bulletin'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.volunteer_activism,
                  title: 'Giving',
                  onTap: () => context.push('/giving'),
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
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
