import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/announcement.dart';
import 'models/issue_report.dart';
import 'screens/main_navigation.dart';

void main() async {
  // 1. Initialize Flutter bindings first (Required since main is async)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive
  await Hive.initFlutter();

  // 3. Register our generated TypeAdapters
  Hive.registerAdapter(AnnouncementAdapter());
  Hive.registerAdapter(IssueReportAdapter());

  // 4. Open the two required boxes
  await Hive.openBox<Announcement>('announcements');
  await Hive.openBox<IssueReport>('issue_reports');

  // 5. Run the app
  runApp(const BarangayBulletinApp());
}

class BarangayBulletinApp extends StatelessWidget {
  const BarangayBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // The old Scaffold is completely gone, replaced cleanly by MainNavigation
      home: const MainNavigation(),
    );
  }
}