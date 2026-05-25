import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/announcement.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Info',
    'Event',
    'Emergency',
    'Health',
    'Education',
    'Sports',
    'Environment',
    'Public Service',
  ];

  String _searchQuery = '';

  List<Announcement> _getFilteredAnnouncements() {
    final box = Hive.box<Announcement>('announcements');

    // load all non-deleted announcements
    List<Announcement> all = box.values
        .where((a) => a.isDeleted == false)
        .toList();

    // apply category filter
    if (_selectedCategory != 'All') {
      all = all.where((a) => a.category == _selectedCategory).toList();
    }

    // apply search filter
    if (_searchQuery.isNotEmpty) {
      all = all.where((a) {
        return a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.body.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // sort pinned first then date descending
    all.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.datePosted.compareTo(a.datePosted);
    });

    return all;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Emergency':
        return Colors.red;

      case 'Event':
        return Colors.green;

      case 'Info':
        return Colors.blue;

      case 'Health':
        return Colors.purple;

      case 'Education':
        return Colors.indigo;

      case 'Sports':
        return Colors.orange;

      case 'Environment':
        return Colors.teal;

      case 'Public Service':
        return Colors.brown;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign),
                        SizedBox(width: 8),
                        Text(
                          'Community Board',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stay updated with the latest barangay announcements.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // category filter chips
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

          // announcement list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Announcement>(
                'announcements',
              ).listenable(),
              builder: (context, box, _) {
                final announcements = _getFilteredAnnouncements();

                // empty state ui
                if (announcements.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No announcements yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                        '${a.datePosted.day}/${a.datePosted.month}/${a.datePosted.year}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            a.category,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          a.category,
                          style: TextStyle(
                            color: _getCategoryColor(a.category),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        // nav to detail screen
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
        heroTag: 'announcements_fab',
        onPressed: () async {
          // add new announcement
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
