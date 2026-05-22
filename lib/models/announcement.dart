import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'announcement.g.dart';

@HiveType(typeId: 0)
class Announcement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime datePosted;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  DateTime? deletedAt;

  Announcement({
    String? id,
    required this.title,
    required this.body,
    required this.category,
    DateTime? datePosted,
    this.isPinned = false,
    this.isDeleted = false,
    this.deletedAt,
  })  : id = id ?? const Uuid().v4(),
        datePosted = datePosted ?? DateTime.now();
}