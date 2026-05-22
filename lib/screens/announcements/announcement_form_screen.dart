import 'package:flutter/material.dart';
import '../../models/announcement.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final Announcement? announcement;

  const AnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String? _category;
  bool _isPinned = false;

  // The exact categories required by the PRD
  final List<String> _categories = ['Info', 'Event', 'Emergency', 'Health'];

  @override
  void initState() {
    super.initState();
    // If editing, populate the fields with existing data. If creating, leave blank.
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _bodyController = TextEditingController(text: widget.announcement?.body ?? '');
    _category = widget.announcement?.category;
    _isPinned = widget.announcement?.isPinned ?? false;
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // Validates the title, body, and dropdown
    if (_formKey.currentState!.validate()) {
      
      // Create the object with the new data
      final savedAnnouncement = Announcement(
        id: widget.announcement?.id, // Keep existing ID if editing
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        category: _category!,
        isPinned: _isPinned,
        datePosted: widget.announcement?.datePosted, // Keep original date if editing
        isDeleted: widget.announcement?.isDeleted ?? false,
        deletedAt: widget.announcement?.deletedAt,
      );

      // Return the object back to the parent screen!
      Navigator.pop(context, savedAnnouncement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                maxLength: 120, // PRD requirement
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) => value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Body is required' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Pin this announcement'),
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null), // Cancel returns null
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saveForm,
                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}