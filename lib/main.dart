import 'package:flutter/material.dart';
import './pages/home_page.dart';
import './pages/settings_page.dart';
import './services/base_url_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BaseUrlService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // === Global reusable colors - All in one place for easy editing ===
  static const Color tealColor = Color(0xFF00796B);

  // Changed gold to coral for better contrast with teal
  static const Color contrastColor = Color(0xFFFF6F61); // Coral

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF212121);

  static const Color lightCardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF424242);

  static const Color lightOnCardTextColor =
      Colors.grey; // e.g. Color(0xFF616161)
  static const Color darkOnCardTextColor =
      Colors.grey; // e.g. Color(0xFFEEEEEE)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salinité App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: tealColor,
          onPrimary: lightOnCardTextColor,
          secondary: contrastColor,
          onSecondary: Colors.black87,
          background: lightBackground,
          onBackground: Colors.grey[900]!,
          surface: lightCardColor,
          onSurface: lightOnCardTextColor,
          error: Colors.red.shade700,
          onError: Colors.black,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: tealColor,
          foregroundColor: Colors.grey[100],
          elevation: 4,
        ),
        cardTheme: CardThemeData(
          color: lightCardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: tealColor.withOpacity(0.25),
        ),
        textTheme: Typography.blackMountainView
            .apply(bodyColor: Colors.white, displayColor: Colors.white)
            .copyWith(
              labelLarge: const TextStyle(color: lightOnCardTextColor),
              bodySmall: const TextStyle(color: Colors.black),
              bodyMedium: const TextStyle(color: darkBackground),
              titleLarge: const TextStyle(
                color: Colors.black,
              ), // << Add this line
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: tealColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: tealColor,
          onPrimary: lightOnCardTextColor,
          secondary: contrastColor,
          onSecondary: Colors.black87,
          background: darkBackground,
          onBackground: Colors.grey[300]!,
          surface: darkCardColor,
          onSurface: darkOnCardTextColor,
          error: Colors.red.shade400,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: tealColor,
          foregroundColor: Colors.grey[900],
          elevation: 4,
        ),
        cardTheme: CardThemeData(
          color: darkCardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.black54,
        ),
        textTheme: Typography.whiteMountainView
            .apply(bodyColor: Colors.grey[300], displayColor: Colors.grey[300])
            .copyWith(
              labelLarge: const TextStyle(color: darkOnCardTextColor),
              bodySmall: const TextStyle(color: Colors.white),
              titleLarge: const TextStyle(
                color: Colors.white,
              ), // << Add this line
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: contrastColor,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
