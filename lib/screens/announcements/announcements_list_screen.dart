import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/announcement.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Info', 'Event', 'Emergency', 'Health'];

  List<Announcement> _getFilteredAnnouncements() {
    final box = Hive.box<Announcement>('announcements');

    // Load all non-deleted announcements once
    List<Announcement> all = box.values
        .where((a) => a.isDeleted == false)
        .toList();

    // Apply category filter
    if (_selectedCategory != 'All') {
      all = all.where((a) => a.category == _selectedCategory).toList();
    }

    // Pinned items first, then sort by datePosted descending
    all.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.datePosted.compareTo(a.datePosted);
    });

    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),

          // List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Announcement>('announcements').listenable(),
              builder: (context, box, _) {
                final announcements = _getFilteredAnnouncements();

                // Empty state
                if (announcements.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No announcements yet.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final a = announcements[index];
                    return ListTile(
                      leading: a.isPinned
                          ? const Icon(Icons.push_pin, color: Color(0xFFE91E8C))
                          : const Icon(Icons.campaign_outlined),
                      title: Text(a.title),
                      subtitle: Text(
                        '${a.category} • ${a.datePosted.day}/${a.datePosted.month}/${a.datePosted.year}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A148C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(a.category,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AnnouncementDetailScreen(announcement: a),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Announcement>(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementFormScreen(),
            ),
          );

          if (result != null) {
            final box = Hive.box<Announcement>('announcements');
            await box.put(result.id, result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}