import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/api_service.dart';
import 'features/about/presentation/screens/about_screen.dart';
import 'core/services/sabbath_reminder_service.dart';
import 'features/sabbath/presentation/screens/sabbath_detail_screen.dart';
import 'core/services/sunset_service.dart';
import 'features/auth/presentation/providers/user_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
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

  try {
    // 初始化API服务
    ApiService().init();

    // 初始化 bulletin 数据
    try {
      await initializeBulletins();
    } catch (e) {
      debugPrint('Failed to initialize bulletins: $e');
      // 不阻止应用启动
    }

    // 初始化通知（添加错误处理）
    try {
      await SabbathReminderService.initializeNotifications();
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      // 不阻止应用启动
    }

    // 使用预设日落时间调度提醒
    final fridaySunset = SunsetService.getThisFridaySunset();
    final saturdaySunset = SunsetService.getThisSaturdaySunset();

    // 如果时间还没过，才调度提醒
    if (fridaySunset.isAfter(DateTime.now())) {
      try {
        await SabbathReminderService.scheduleSabbathReminders(
          fridaySunset,
          saturdaySunset,
        );
      } catch (e) {
        debugPrint('Failed to schedule reminders: $e');
      }
    }

    if (!kIsWeb) {
      try {
        await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
        Workmanager().registerPeriodicTask(
          'publish-scheduled',
          'publishScheduled',
          frequency: const Duration(hours: 1),
        );
      } catch (e) {
        debugPrint('Failed to initialize Workmanager: $e');
      }
    }
  } catch (e) {
    debugPrint('Error during initialization: $e');
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
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Giving',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Sabbath',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Volunteer'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
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

    // 主路由 - 使用 StatefulShellRoute 来管理底部导航
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 首页分支 - 包含编辑页面
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                // 编辑页面作为 home 的子路由
                GoRoute(
                  path: 'bulletin/edit',
                  builder: (context, state) {
                    final extra = state.extra as Map?;
                    return EditBulletinScreen(
                      item: extra?['item'],
                      onSave: extra?['refresh'],
                      dayOfWeek: extra?['dayOfWeek'],
                    );
                  },
                ),
              ],
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
        // 安息日分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sabbath',
              builder: (context, state) => const SabbathDetailScreen(),
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
      theme: _buildTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // 添加全局错误边界
        ErrorWidget.builder = (details) {
          return Material(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('An error occurred', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(
                      details.exception.toString(),
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return child!;
      },
    );
  }

  ThemeData _buildTheme() {
    // 修改为带灰青色调的背景色
    const Color primaryColor = Color(0xFF4A7A9C);
    const Color accentColor = Color(0xFF278F8F);
    const Color backgroundColor = Color(0xFFE8ECF0); // 带灰青色调的背景色
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
      // 硅胶感按钮样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // 使用渐变背景色
          backgroundColor: const Color(0xFFF4F6F8),
          foregroundColor: primaryColor,
          elevation: 0, // 使用自定义阴影而非系统阴影
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          textStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).copyWith(
          // 外阴影: 左上浅色,右下深色
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      // OutlinedButton 使用同样的硅胶感样式
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          // 使用渐变背景色
          backgroundColor: const Color(0xFFF4F6F8),
          foregroundColor: primaryColor,
          side: BorderSide.none,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          textStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // TextButton 也使用硅胶感样式
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // 使用渐变背景色
          backgroundColor: const Color(0xFFF4F6F8),
          foregroundColor: primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          textStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
      // TabBar 样式 - 选中的标签显示背景 - 使用新的渐变和阴影
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: primaryColor.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          // 使用渐变背景色
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB6B9BA),
              Color(0xFFF4F6F8),
            ],
            begin: FractionalOffset(0.5, 1.0),
            end: FractionalOffset(0.5, 0.0),
            stops: [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          // 硅胶感外阴影
          boxShadow: [
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
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
