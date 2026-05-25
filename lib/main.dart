import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/announcement.dart';
import 'models/issue_report.dart';
import 'main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    Hive.registerAdapter(AnnouncementAdapter());
    Hive.registerAdapter(IssueReportAdapter());

    await Hive.openBox<Announcement>('announcements');
    await Hive.openBox<IssueReport>('issue_reports');

    runApp(const BarangayBulletinApp());

  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize local storage.\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class BarangayBulletinApp extends StatelessWidget {
  const BarangayBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // sets up app theme and root root navigation
    return MaterialApp(
      title: 'Barangay Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A148C),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A148C),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE91E8C),
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          selectedColor: const Color(0xFF4A148C).withOpacity(0.2),
          backgroundColor: Colors.grey.shade100,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.black87),
          secondaryLabelStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4A148C),
          ),
          checkmarkColor: const Color(0xFF4A148C),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A148C),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4A148C), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF4A148C),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}