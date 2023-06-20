import 'package:today_safety/const/value/key.dart';

class ModelConstraintLocation {
  final int range;

  ModelConstraintLocation.fromJson(Map json) : range = json[keyRange] ?? 1000;

  Map<String, dynamic> toJson() {
    return {
      keyRange: range,
    };
  }
}
