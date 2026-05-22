import 'package:flutter/material.dart';
import '../../models/issue_report.dart';

class ReportFormScreen extends StatefulWidget {
  final IssueReport? report;

  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.report != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Report' : 'New Report'),
      ),
      body: Center(
        child: Text(isEditing ? 'Editing Form' : 'Creation Form'),
      ),
    );
  }
}