import 'package:flutter/material.dart';
import '../../models/issue_report.dart';

class ReportDetailScreen extends StatelessWidget {
  final IssueReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: Center(
        child: Text('Viewing Details for: ${report.title}'),
      ),
    );
  }
}