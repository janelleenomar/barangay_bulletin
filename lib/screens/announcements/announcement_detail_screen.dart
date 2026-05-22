import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/announcement.dart';
import 'announcement_form_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  late Announcement _announcement;

  @override
  void initState() {
    super.initState();
    _announcement = widget.announcement;
  }

  // PIN / UNPIN
  Future<void> _togglePin() async {
    setState(() => _announcement.isPinned = !_announcement.isPinned);
    await _announcement.save(); // HiveObject's built-in save()
  }

  // SOFT DELETE
  Future<void> _softDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('This will move the announcement to the Archive. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _announcement.isDeleted = true;
        _announcement.deletedAt = DateTime.now();
      });
      await _announcement.save();
      if (mounted) Navigator.pop(context);
    }
  }

  // EDIT
  Future<void> _edit() async {
    final result = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormScreen(announcement: _announcement),
      ),
    );

    if (result != null) {
      // Update fields on the existing Hive object
      setState(() {
        _announcement.title = result.title;
        _announcement.body = result.body;
        _announcement.category = result.category;
        _announcement.isPinned = result.isPinned;
      });
      await _announcement.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMMM d, yyyy').format(_announcement.datePosted);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
        actions: [
          // Pin/Unpin toggle
          IconButton(
            icon: Icon(
              _announcement.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _announcement.isPinned ? const Color(0xFFE91E8C) : Colors.white,
            ),
            tooltip: _announcement.isPinned ? 'Unpin' : 'Pin',
            onPressed: _togglePin,
          ),
          // Edit
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
          // Soft delete
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _softDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A148C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _announcement.category,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              _announcement.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Date + pinned status
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dateFormatted, style: const TextStyle(color: Colors.grey)),
                if (_announcement.isPinned) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.push_pin, size: 14, color: Color(0xFFE91E8C)),
                  const Text(' Pinned', style: TextStyle(color: Color(0xFFE91E8C), fontSize: 13)),
                ]
              ],
            ),
            const Divider(height: 32),

            // Body
            Text(
              _announcement.body,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}