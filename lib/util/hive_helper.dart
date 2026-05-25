import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {

  static Box<T>? getBox<T>(String name) {

    try {

      if (Hive.isBoxOpen(name)) {
        return Hive.box<T>(name);
      }

      return null;

    } catch (e) {
      return null;
    }
  }
}