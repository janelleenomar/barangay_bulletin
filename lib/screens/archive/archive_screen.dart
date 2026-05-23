import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/announcement.dart';
import '../../models/issue_report.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Announcements', 'Reports'];

  // combine boxes and return soft-deleted entries
  List<Map<String, dynamic>> _getArchivedItems() {
    final List<Map<String, dynamic>> items = [];

    // filter selector logic
    if (_selectedFilter == 'All' || _selectedFilter == 'Announcements') {
      final announcementBox = Hive.box<Announcement>('announcements');
      final deleted = announcementBox.values
          .where((a) => a.isDeleted == true)
          .toList();
      for (final a in deleted) {
        items.add({
          'type': 'Announcement',
          'title': a.title,
          'deletedAt': a.deletedAt,
          'object': a,
        });
      }
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Reports') {
      final reportBox = Hive.box<IssueReport>('issue_reports');
      final deleted = reportBox.values
          .where((r) => r.isDeleted == true)
          .toList();
      for (final r in deleted) {
        items.add({
          'type': 'Report',
          'title': r.title,
          'deletedAt': r.deletedAt,
          'object': r,
        });
      }
    }

    // sort by deleted date descending
    items.sort((a, b) {
      final aDate = a['deletedAt'] as DateTime?;
      final bDate = b['deletedAt'] as DateTime?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return items;
  }

  // restore function
  Future<void> _restore(dynamic object) async {
    if (object is Announcement) {
      object.isDeleted = false;
      object.deletedAt = null;
      await object.save();
    } else if (object is IssueReport) {
      object.isDeleted = false;
      object.deletedAt = null;
      await object.save();
    }
  }

  // hard delete function
  Future<void> _hardDelete(dynamic object) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete'),
        content: const Text(
          'This cannot be undone. The item will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete Forever',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (object is Announcement) {
        await object.delete(); // hive hard delete
      } else if (object is IssueReport) {
        await object.delete();
      }
      setState(() {}); // refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: Column(
        children: [
          // type filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              },
            ),
          ),

          // archived items list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Announcement>(
                'announcements',
              ).listenable(),
              builder: (context, _, __) {
                return ValueListenableBuilder(
                  valueListenable: Hive.box<IssueReport>(
                    'issue_reports',
                  ).listenable(),
                  builder: (context, _, __) {
                    final items = _getArchivedItems();

                    // empty state ui
                    if (items.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.archive_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nothing in the archive.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final type = item['type'] as String;
                        final title = item['title'] as String;
                        final deletedAt = item['deletedAt'] as DateTime?;
                        final object = item['object'];

                        final deletedAtFormatted = deletedAt != null
                            ? DateFormat('MMM d, yyyy').format(deletedAt)
                            : 'Unknown date';

                        return Dismissible(
                          key: Key(
                            object is Announcement
                                ? object.id
                                : (object as IssueReport).id,
                          ),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            color: const Color(0xFF4A148C),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Row(
                              children: [
                                Icon(Icons.restore, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Restore',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            await _restore(object);
                            return false; // rebuild handles removal
                          },
                          child: ListTile(
                            leading: Icon(
                              type == 'Announcement'
                                  ? Icons.campaign_outlined
                                  : Icons.report_problem_outlined,
                              color: Colors.grey,
                            ),
                            title: Text(title),
                            subtitle: Text(
                              '$type • Deleted $deletedAtFormatted',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // restore button action
                                IconButton(
                                  icon: const Icon(
                                    Icons.restore,
                                    color: Color(0xFF7B1FA2),
                                  ),
                                  tooltip: 'Restore',
                                  onPressed: () => _restore(object),
                                ),
                                // hard delete button action
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete Forever',
                                  onPressed: () => _hardDelete(object),
                                ),
                              ],
                            ),
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
    );
  }
}
