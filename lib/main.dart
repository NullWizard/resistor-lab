import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';

/// The entry point of the Resistor Lab application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Notice: Could not load .env configuration file.");
  }
  runApp(const ResistorLabApp());
}

/// Root widget of the Resistor Lab application.
///
/// Configures a clean Material 3 academic theme suitable for
/// a college Basic Electronics Lab demonstration.
class ResistorLabApp extends StatelessWidget {
  const ResistorLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    // High-Precision Obsidian Engineering Theme
    const darkBackground = Color(0xFF030712); // Deep obsidian space canvas
    const darkSurface = Color(0xFF0F172A);    // Frosted glass base tint
    const darkBorder = Color(0xFF1E293B);     // Crisp slate divider / border
    const electricCyan = Color(0xFF00E5FF);   // Cyber Cyan primary accent
    const amberAccent = Color(0xFFF59E0B);    // Electric Amber indicator
    const emeraldAccent = Color(0xFF10B981);  // Digital Emerald

    return MaterialApp(
      title: 'Resistor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: electricCyan,
          onPrimary: Color(0xFF080D1A),
          primaryContainer: Color(0xFF0E3A4A),
          onPrimaryContainer: Color(0xFF67E8F9),
          secondary: amberAccent,
          onSecondary: Color(0xFF080D1A),
          secondaryContainer: Color(0xFF451A03),
          onSecondaryContainer: Color(0xFFFDE68A),
          tertiary: emeraldAccent,
          surface: darkSurface,
          onSurface: Color(0xFFF8FAFC),
          onSurfaceVariant: Color(0xFF94A3B8),
          outline: darkBorder,
          outlineVariant: Color(0xFF334155),
        ),
        scaffoldBackgroundColor: darkBackground,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: darkBackground,
          foregroundColor: Color(0xFFF8FAFC),
          titleTextStyle: TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: darkBorder, width: 1.2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: electricCyan,
            foregroundColor: const Color(0xFF080D1A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFF8FAFC),
            side: const BorderSide(color: Color(0xFF334155), width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
