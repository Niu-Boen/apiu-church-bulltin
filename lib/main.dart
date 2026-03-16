import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'features/about/presentation/screens/about_screen.dart';
import 'core/services/sabbath_reminder_service.dart';
// import 'features/sabbath/data/sabbath_info_service.dart';
import 'features/sabbath/presentation/screens/sabbath_detail_screen.dart';
import 'core/services/sunset_service.dart';

import 'features/auth/presentation/providers/user_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/bulletin/presentation/screens/bulletin_screen.dart';
import 'features/bulletin/presentation/screens/edit_bulletin_screen.dart';
import 'features/giving/presentation/screens/giving_screen.dart';
import 'features/volunteer/presentation/screens/volunteer_screen.dart';
import 'features/bulletin/data/bulletin_data.dart';
import 'features/bulletin/presentation/widgets/bulletin_item_model.dart';

// 后台任务回调
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final now = DateTime.now();
    final toPublish = bulletinItems
        .where(
          (item) =>
              item.isDraft &&
              item.scheduledDate != null &&
              item.scheduledDate!.isBefore(now),
        )
        .toList();

    for (var item in toPublish) {
      final index = bulletinItems.indexOf(item);
      if (index != -1) {
        bulletinItems[index] = BulletinItem(
          title: item.title,
          time: item.time,
          description: item.description,
          servicePersonnel: item.servicePersonnel,
          icon: item.icon,
          publishDate: now,
          isDraft: false,
          scheduledDate: null,
        );
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知
  await SabbathReminderService.initializeNotifications();

  // 使用预设日落时间调度提醒
  final fridaySunset = SunsetService.getThisFridaySunset();
  final saturdaySunset = SunsetService.getThisSaturdaySunset();

  // 如果时间还没过，才调度提醒
  if (fridaySunset.isAfter(DateTime.now())) {
    await SabbathReminderService.scheduleSabbathReminders(
      fridaySunset,
      saturdaySunset,
    );
  }

  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask(
      'publish-scheduled',
      'publishScheduled',
      frequency: const Duration(hours: 1),
    );
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const APIUBulletinApp(),
    ),
  );
}

// 底部导航栏包装组件
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Bulletin'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Giving',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Sabbath',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Volunteer'),
        ],
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // 在 main.dart 中找到 StatefulShellRoute 部分，修改为：
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 首页分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // 公告分支（包含编辑页）
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bulletin',
              builder: (context, state) => const BulletinScreen(),
            ),
            GoRoute(
              path: '/edit-bulletin',
              builder: (context, state) {
                final extra = state.extra as Map?;
                return EditBulletinScreen(
                  item: extra?['item'],
                  onSave: extra?['refresh'],
                );
              },
            ),
            GoRoute(
              path: '/sabbath',
              builder: (context, state) => const SabbathDetailScreen(),
            ),
          ],
        ),
        // 奉献分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/giving',
              builder: (context, state) => const GivingScreen(),
            ),
          ],
        ),
        // 志愿者分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/volunteer',
              builder: (context, state) => const VolunteerScreen(),
            ),
          ],
        ),
        // 关于我们分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/about',
              builder: (context, state) => const AboutScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class APIUBulletinApp extends StatelessWidget {
  const APIUBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'APIU Bulletin',
      theme: _buildThemeData(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildThemeData() {
    const Color primaryColor = Color(0xFF4A7A9C);
    const Color accentColor = Color(0xFF278F8F);
    const Color backgroundColor = Color(0xFFF2F5F8);
    const Color cardColor = Colors.white;
    const double borderRadius = 16.0;
    const double buttonVerticalPadding = 16.0;
    const double buttonHorizontalPadding = 24.0;
    const double appBarElevation = 2.0;
    // const double cardElevation = 2.0;

    final baseTextTheme = GoogleFonts.ptSansTextTheme();
    final textTheme = baseTextTheme
        .copyWith(
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14),
        )
        .apply(
          bodyColor: primaryColor.withValues(alpha: 0.8),
          displayColor: primaryColor,
        );

    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryColor.withValues(alpha: 0.8),
      error: Colors.red,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: appBarElevation,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 暂时注释以避免类型错误
      // cardTheme: CardTheme(
      //   elevation: cardElevation,
      //   color: cardColor,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(borderRadius),
      //   ),
      //   shadowColor: primaryColor.withValues(alpha: 0.1),
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: primaryColor.withValues(alpha: 0.6),
      ),
      // tabBarTheme: TabBarTheme(
      //   indicator: BoxDecoration(
      //     color: cardColor,
      //     borderRadius: BorderRadius.circular(borderRadius),
      //     boxShadow: [
      //       BoxShadow(
      //         color: primaryColor.withValues(alpha: 0.1),
      //         blurRadius: 4,
      //         offset: const Offset(0, 2),
      //       ),
      //     ],
      //   ),
      //   labelColor: primaryColor,
      //   unselectedLabelColor: primaryColor.withValues(alpha: 0.7),
      //   indicatorSize: TabBarIndicatorSize.tab,
      // ),
    );
  }
}
