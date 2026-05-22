import 'package:flutter/material.dart';
import '../../models/announcement.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  // Receives the exact announcement the user tapped on
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement Details')),
      body: Center(
        child: Text('Viewing Details for: ${announcement.title}'),
      ),
    );
  }
}