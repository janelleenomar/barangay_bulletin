import 'package:flutter/material.dart';
import '../../models/announcement.dart';

class AnnouncementFormScreen extends StatefulWidget {
  // Null = Create Mode, Non-null = Edit Mode
  final Announcement? announcement;

  const AnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
      ),
      body: Center(
        child: Text(isEditing ? 'Editing Form' : 'Creation Form'),
      ),
    );
  }
}