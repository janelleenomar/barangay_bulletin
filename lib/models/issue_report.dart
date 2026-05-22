import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'issue_report.g.dart';

@HiveType(typeId: 1)
class IssueReport extends HiveObject {
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

  IssueReport({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'Pending',
    DateTime? dateReported,
    this.isDeleted = false,
    this.deletedAt,
  })  : id = id ?? const Uuid().v4(),
        dateReported = dateReported ?? DateTime.now();
}