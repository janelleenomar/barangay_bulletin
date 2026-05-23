import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// generate hive adapter file
part 'issue_report.g.dart';

// define issue report model for database
@HiveType(typeId: 1)
class IssueReport extends HiveObject {
  // define document fields
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime dateReported;

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  DateTime? deletedAt;

  // issue report constructor
  IssueReport({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'Pending',
    DateTime? dateReported,
    this.isDeleted = false,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4(), // auto generate id
       dateReported = dateReported ?? DateTime.now(); // set report date
}
