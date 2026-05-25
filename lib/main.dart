import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/announcement.dart';
import 'models/issue_report.dart';
import 'screens/announcements/announcements_list_screen.dart';
import 'screens/reports/reports_list_screen.dart';
import 'screens/archive/archive_screen.dart';

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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // track current tab
  int _currentIndex = 0;

  final List<String> _titles = ['Announcements', 'Reports', 'Archive'];

  // define screen tabs
  final List<Widget> _screens = [
    const AnnouncementsListScreen(),
    const ReportsListScreen(),
    const ArchiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // scaffold holds main structure and bottom nav
    return Scaffold(
      // indexed stack keeps states alive
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        // updates current tab index
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF4A148C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            activeIcon: Icon(Icons.archive),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}
