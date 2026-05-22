import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/issue_report.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final IssueReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late IssueReport _report;

  final List<String> _statuses = ['Pending', 'In Progress', 'Resolved'];

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

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  // STATUS UPDATE directly from detail screen (PRD requirement)
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _report.status = newStatus);
    await _report.save();
  }

  // SOFT DELETE
  Future<void> _softDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
            'This will move the report to the Archive. Continue?'),
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
        _report.isDeleted = true;
        _report.deletedAt = DateTime.now();
      });
      await _report.save();
      if (mounted) Navigator.pop(context);
    }
  }

  // EDIT
  Future<void> _edit() async {
    final result = await Navigator.push<IssueReport>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportFormScreen(report: _report),
      ),
    );

    if (result != null) {
      setState(() {
        _report.title = result.title;
        _report.description = result.description;
        _report.category = result.category;
        _report.status = result.status;
      });
      await _report.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('MMMM d, yyyy').format(_report.dateReported);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A148C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _report.category,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              _report.title,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dateFormatted,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 32),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              _report.description,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const Divider(height: 32),

            // Status update shortcut (PRD requirement)
            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _statuses.map((status) {
                final isSelected = _report.status == status;
                return GestureDetector(
                  onTap: () => _updateStatus(status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _statusColor(status)
                          : _statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _statusColor(status),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isSelected ? Colors.white : _statusColor(status),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}