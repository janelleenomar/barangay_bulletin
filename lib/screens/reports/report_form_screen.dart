import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/issue_report.dart';

class ReportFormScreen extends StatefulWidget {
  final IssueReport? report;

  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _category;
  String _status = 'Pending';

  // form constants
  final List<String> _categories = [
    'Road',
    'Power',
    'Water',
    'Safety',
    'Other',
  ];
  final List<String> _statuses = ['Pending', 'In Progress', 'Resolved'];

  bool get _isEditMode => widget.report != null;

  @override
  void initState() {
    super.initState();
    // populate if edit mode
    _titleController = TextEditingController(text: widget.report?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.report?.description ?? '',
    );
    _category = widget.report?.category;
    _status = widget.report?.status ?? 'Pending';
  }

  @override
  void dispose() {
    // avoid memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // validate form fields
    if (_formKey.currentState!.validate()) {
      // create report object
      final savedReport = IssueReport(
        id: widget.report?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category!,
        status: _status,
        dateReported: widget.report?.dateReported ?? DateTime.now(),
        isDeleted: widget.report?.isDeleted ?? false,
        deletedAt: widget.report?.deletedAt,
      );

      // return to previous screen
      Navigator.pop(context, savedReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Report' : 'New Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // title text field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),

              // description text field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // status dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 24),

              // action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saveForm,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
