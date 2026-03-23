import 'package:flutter/material.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final Map<String, bool> _signedUpServices = {
    'greeting': false,
    'av': false,
    'music': false,
    'cleaning': false,
    'hospitality': false,
    'tech_support': false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Opportunities'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎信息
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: theme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Make a Difference',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign up for volunteer opportunities and serve our community. Your help makes a difference!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 志愿服务列表
            Text(
              'Available Services',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildVolunteerCard(
              theme,
              'greeting',
              'Greeting Team',
              'Welcome visitors and members to our church services',
              Icons.waving_hand_rounded,
              Colors.green,
            ),
            _buildVolunteerCard(
              theme,
              'av',
              'AV & Sound',
              'Manage audio-visual equipment and sound system',
              Icons.settings_remote_rounded,
              Colors.blue,
            ),
            _buildVolunteerCard(
              theme,
              'music',
              'Music Ministry',
              'Join the choir or play an instrument',
              Icons.music_note_rounded,
              Colors.purple,
            ),
            _buildVolunteerCard(
              theme,
              'cleaning',
              'Cleaning Team',
              'Help keep our church clean and welcoming',
              Icons.cleaning_services_rounded,
              Colors.orange,
            ),
            _buildVolunteerCard(
              theme,
              'hospitality',
              'Hospitality',
              'Prepare refreshments and assist with events',
              Icons.coffee_rounded,
              Colors.brown,
            ),
            _buildVolunteerCard(
              theme,
              'tech_support',
              'Tech Support',
              'Help with IT, website, and digital communications',
              Icons.computer_rounded,
              Colors.cyan,
            ),

            const SizedBox(height: 24),

            // 我的志愿服务
            if (_signedUpServices.containsValue(true)) ...[
              Text(
                'My Sign-ups',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
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
                      ..._signedUpServices.entries
                          .where((entry) => entry.value)
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getServiceName(entry.key),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )),
                      const SizedBox(height: 8),
                      Text(
                        'Thank you for your service! 🙏',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerCard(
    ThemeData theme,
    String serviceKey,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSignedUp = _signedUpServices[serviceKey] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _signedUpServices[serviceKey] = !isSignedUp;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isSignedUp
                    ? 'Removed from $title'
                    : 'Signed up for $title',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSignedUp ? Colors.green : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isSignedUp
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceName(String key) {
    switch (key) {
      case 'greeting':
        return 'Greeting Team';
      case 'av':
        return 'AV & Sound';
      case 'music':
        return 'Music Ministry';
      case 'cleaning':
        return 'Cleaning Team';
      case 'hospitality':
        return 'Hospitality';
      case 'tech_support':
        return 'Tech Support';
      default:
        return 'Unknown Service';
    }
  }
}
