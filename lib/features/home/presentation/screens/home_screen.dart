import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildWelcomeHeader(textTheme, theme),
            const SizedBox(height: 24),
            _buildSabbathCard(context),
            const SizedBox(height: 24),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(TextTheme textTheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          const SizedBox(height: 4),
          Text(
            'Stay updated with the latest announcements and events.',
            style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSabbathCard(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 4, // Slightly more shadow for emphasis
      shadowColor: theme.primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.wb_twilight_rounded, size: 40, color: theme.primaryColor),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sabbath Hours', style: textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Friday Sunset: 6:45 PM', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8))),
                  Text('Saturday Sunset: 6:45 PM', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
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
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
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
            Icon(icon, size: 40, color: theme.colorScheme.secondary),
            const SizedBox(height: 12),
            Text(
              title, 
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), 
              textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }
}
