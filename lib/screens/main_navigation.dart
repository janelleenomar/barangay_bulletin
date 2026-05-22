import 'package:flutter/material.dart';

import 'announcements/announcements_list_screen.dart';
import 'reports/reports_list_screen.dart';
import 'archive/archive_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // We use setState to update this index when a tab is tapped
  int _currentIndex = 0;

  // The list of screens our IndexedStack will hold
  final List<Widget> _screens = const [
    AnnouncementsListScreen(),
    ReportsListScreen(),
    ArchiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state of tabs when switching
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign), 
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}