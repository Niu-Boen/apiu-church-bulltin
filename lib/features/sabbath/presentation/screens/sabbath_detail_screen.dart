import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/sabbath_info_service.dart';
import '../../domain/models/sabbath_service.dart';

class SabbathDetailScreen extends StatefulWidget {
  const SabbathDetailScreen({super.key});

  @override
  State<SabbathDetailScreen> createState() => _SabbathDetailScreenState();
}

class _SabbathDetailScreenState extends State<SabbathDetailScreen> {
  late Map<String, DateTime> _sunsetTimes;
  late List<SabbathService> _fridayServices;
  late List<SabbathService> _saturdayServices;

  @override
  void initState() {
    super.initState();
    _sunsetTimes = SabbathInfoService.getThisWeekSunsetTimes();
    _fridayServices = SabbathInfoService.getFridayServices();
    _saturdayServices = SabbathInfoService.getSaturdayServices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('This Week\'s Sabbath'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日落时间卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSunsetRow(
                      'Friday Sunset',
                      _sunsetTimes['friday']!,
                      Icons.wb_twilight,
                      theme,
                    ),
                    const Divider(height: 24),
                    _buildSunsetRow(
                      'Saturday Sunset',
                      _sunsetTimes['saturday']!,
                      Icons.wb_sunny,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 周五流程
            Text(
              'Friday Evening Service',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildServiceList(_fridayServices, theme),

            const SizedBox(height: 24),

            // 周六流程
            Text(
              'Sabbath Morning Service',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildServiceList(_saturdayServices, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSunsetRow(
      String label, DateTime time, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        const Spacer(),
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

  List<Widget> _buildServiceList(
      List<SabbathService> services, ThemeData theme) {
    return services.map((service) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                service.time,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
                    ),
                  ),
                  if (service.description != null &&
                      service.description!.isNotEmpty)
                    Text(
                      service.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  if (service.personnel != null &&
                      service.personnel!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.personnel!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
