import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/issue_report.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';

  final List<String> _statuses = ['All', 'Pending', 'In Progress', 'Resolved'];
  final List<String> _categories = [
    'All',
    'Road',
    'Power',
    'Water',
    'Safety',
    'Other',
  ];

  // status specific colors
  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFE91E8C); // pink
      case 'In Progress':
        return const Color(0xFF7B1FA2); // medium purple
      case 'Resolved':
        return const Color(0xFF4A148C); // deep purple
      default:
        return Colors.grey;
    }
  }

  List<IssueReport> _getFilteredReports() {
    final box = Hive.box<IssueReport>('issue_reports');

    // fetch non-deleted reports
    List<IssueReport> all = [];

    for (final report in box.values) {
      try {
        if (report.isDeleted == false) {
          all.add(report);
        }
      } catch (e) {
        debugPrint('Corrupted report skipped: $e');
      }
    }

    // filter by status
    if (_selectedStatus != 'All') {
      all = all.where((r) => r.status == _selectedStatus).toList();
    }

    // filter by category
    if (_selectedCategory != 'All') {
      all = all.where((r) => r.category == _selectedCategory).toList();
    }

    // sort date descending
    all.sort((a, b) => b.dateReported.compareTo(a.dateReported));

    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          // status filter chips ui
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: isSelected && status != 'All'
                        ? _statusColor(status).withOpacity(0.3)
                        : null,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                  ),
                );
              },
            ),
          ),

          // category drop down filter ui
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ),
          const SizedBox(height: 8),

          // reports list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<IssueReport>(
                'issue_reports',
              ).listenable(),
              builder: (context, box, _) {
                final reports = _getFilteredReports();

                // empty state ui
                if (reports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report_problem_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No reports yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final r = reports[index];
                    return ListTile(
                      leading: const Icon(Icons.report_problem_outlined),
                      title: Text(r.title),
                      subtitle: Text(
                        '${r.category} • ${r.dateReported.day}/${r.dateReported.month}/${r.dateReported.year}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(r.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: _statusColor(r.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // go to details
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailScreen(report: r),
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
        heroTag: 'reports_fab',
        onPressed: () async {
          // add new report
          final result = await Navigator.push<IssueReport>(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
          );

          if (result != null) {
            final box = Hive.box<IssueReport>('issue_reports');
            await box.put(result.id, result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
