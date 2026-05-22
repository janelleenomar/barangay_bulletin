import 'package:flutter/material.dart';
import '../../models/announcement.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Dummy data to test the routing
            final dummyAnnouncement = Announcement(
              title: 'Water Interruption',
              body: 'There will be no water from 1PM to 5PM.',
              category: 'Info',
            );
            
            // Route to Detail Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnouncementDetailScreen(announcement: dummyAnnouncement),
              ),
            );
          },
          child: const Text('Test Detail Route'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Route to Form Screen in Create Mode (passing null)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementFormScreen(),
            ),
          );
          
          if (result != null) {
            // We will save to Hive here in the next step!
            debugPrint('Data returned from form!');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}