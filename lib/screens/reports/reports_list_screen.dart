import 'package:flutter/material.dart';
import '../../models/issue_report.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Dummy data to test the routing
            final dummyReport = IssueReport(
              title: 'Broken Streetlight',
              description: 'The light on Elm St is flickering.',
              category: 'Power',
            );
            
            // Route to Detail Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(report: dummyReport),
              ),
            );
          },
          child: const Text('Test Detail Route'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Route to Form Screen in Create Mode (passing null)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportFormScreen(),
            ),
          );
          
          if (result != null) {
            // We will save to Hive here in the next step!
            debugPrint('Data returned from form!');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}