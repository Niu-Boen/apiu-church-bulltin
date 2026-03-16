import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 常量定义（保持与之前屏幕一致的命名风格）
  static const double _paddingAll = 16.0;
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 24.0;
  static const double _iconSizeLarge = 40.0;
  static const double _cardElevation = 4.0;
  static const double _cardPaddingAll = 20.0;
  static const double _gridCrossAxisSpacing = 16.0;
  static const double _gridMainAxisSpacing = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('APIU Bulletin', style: theme.appBarTheme.titleTextStyle),
        automaticallyImplyLeading: false, // No back button on home
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_paddingAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: _spacingSmall),
            _buildWelcomeHeader(textTheme, theme),
            const SizedBox(height: _spacingMedium),
            _buildSabbathCard(context),
            const SizedBox(height: _spacingMedium),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  /// 构建欢迎头部
  Widget _buildWelcomeHeader(TextTheme textTheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Community',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: _spacingSmall / 2), // 4px
          Text(
            'Stay updated with the latest announcements and events.',
            style: textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建安息日信息卡片
  Widget _buildSabbathCard(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: _cardElevation, // Slightly more shadow for emphasis
      shadowColor: theme.primaryColor.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(_cardPaddingAll),
        child: Row(
          children: [
            Icon(
              Icons.wb_twilight_rounded,
              size: _iconSizeLarge,
              color: theme.primaryColor,
            ),
            const SizedBox(width: _cardPaddingAll),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sabbath Hours',
                    style: textTheme.titleLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: _spacingSmall - 2), // 6px
                  Text(
                    'Friday Sunset: 6:45 PM',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'Saturday Sunset: 6:45 PM',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能网格（4个卡片）
  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: _gridCrossAxisSpacing,
      mainAxisSpacing: _gridMainAxisSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.article_outlined,
          title: 'Weekly Bulletin',
          onTap: () => context.go('/bulletin'),
        ),
        _buildFeatureCard(
          context,
          icon: Icons.event_note_outlined,
          title: 'Upcoming Events',
          onTap: () => context.go('/bulletin'), // Also navigate to Bulletin
        ),
        _buildFeatureCard(
          context,
          icon: Icons.volunteer_activism_outlined,
          title: 'Giving & Tithes',
          onTap: () => context.go('/giving'),
        ),
        _buildFeatureCard(
          context,
          icon: Icons.info_outline,
          title: 'About Us',
          onTap: () {
            // TODO: Navigate to About screen when implemented
          },
        ),
      ],
    );
  }

  /// 构建单个功能卡片
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: _iconSizeLarge, color: theme.colorScheme.secondary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}