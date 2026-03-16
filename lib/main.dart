import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/bulletin/presentation/screens/bulletin_screen.dart';
import 'features/giving/presentation/screens/giving_screen.dart';
import 'features/bulletin/presentation/screens/edit_bulletin_screen.dart';

// --- 1. Router Configuration ---
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

void main() => runApp(const APIUBulletinApp());

// --- 2. Main App Widget ---
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

  // --- 3. Theme Definition ---
  ThemeData _buildThemeData() {
    // --- Base Colors (from UI Specification) ---
    const Color primaryColor = Color.fromAHSL(210, 0.52, 0.55); // HSL 210 52% 55% -> Steel Blue
    const Color accentColor = Color.fromAHSL(180, 0.70, 0.45);  // HSL 180 70% 45% -> Teal
    const Color backgroundColor = Color.fromAHSL(210, 0.14, 0.95); // HSL 210 14% 95% -> Light Grey Blue
    const Color cardColor = Colors.white;

    // --- Base Text Theme ---
    final baseTextTheme = GoogleFonts.ptSansTextTheme();

    final textTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14),
    ).apply(
      bodyColor: primaryColor.withOpacity(0.8),
      displayColor: primaryColor,
    );

    return ThemeData(
      // --- Core Colors ---
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primaryColor.withOpacity(0.8),
        onError: Colors.white,
      ),
      
      // --- Typography ---
      textTheme: textTheme,
      
      // --- Component Themes ---
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // 0.75rem ~ 12px
        ),
        shadowColor: primaryColor.withOpacity(0.1),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: primaryColor.withOpacity(0.6),
      ),

      tabBarTheme: TabBarTheme(
        indicator: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        labelColor: primaryColor,
        unselectedLabelColor: primaryColor.withOpacity(0.7),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      useMaterial3: true,
    );
  }
}
