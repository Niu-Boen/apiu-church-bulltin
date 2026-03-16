import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workmanager/workmanager.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/bulletin/presentation/screens/bulletin_screen.dart';
import 'features/giving/presentation/screens/giving_screen.dart';
import 'features/bulletin/presentation/screens/edit_bulletin_screen.dart';
import 'features/bulletin/data/bulletin_data.dart';
import 'features/bulletin/presentation/widgets/bulletin_item_model.dart';

// 后台任务回调
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final now = DateTime.now();
    final toPublish = bulletinItems.where((item) =>
        item.isDraft && item.scheduledDate != null && item.scheduledDate!.isBefore(now)).toList();

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
    // 可选：发送本地通知
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask(
      'publish-scheduled',
      'publishScheduled',
      frequency: const Duration(hours: 1),
    );
  }
  runApp(const APIUBulletinApp());
}

// ignore: unused_element
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/bulletin', builder: (context, state) => const BulletinScreen()),
    GoRoute(path: '/giving', builder: (context, state) => const GivingScreen()),
    GoRoute(path: '/edit-bulletin', builder: (context, state) => const EditBulletinScreen()),
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
    const double borderRadius = 12.0;
    const double buttonVerticalPadding = 16.0;
    const double buttonHorizontalPadding = 24.0;
    const double appBarElevation = 2.0;
    const double cardElevation = 2.0;

    final baseTextTheme = GoogleFonts.ptSansTextTheme();
    final textTheme = baseTextTheme.copyWith(
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
    ).apply(
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
    // 背景色通过 scaffoldBackgroundColor 单独设置

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
      cardTheme: CardThemeData(
        elevation: cardElevation,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        shadowColor: primaryColor.withValues(alpha: 0.1),
      ),
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
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: primaryColor,
        unselectedLabelColor: primaryColor.withValues(alpha: 0.7),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}