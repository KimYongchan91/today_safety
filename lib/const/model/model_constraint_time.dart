import 'package:today_safety/const/value/key.dart';

class ModelConstraintTime {
  final String start;
  final String end;
  final List<dynamic> week;

  ModelConstraintTime.fromJson(Map json)
      : start = json[keyStart] ?? '0000',
        end = json[keyEnd] ?? '2359',
        week = json[keyWeek] ?? [1, 2, 3, 4, 5, 6, 7];

  Map<String, dynamic> toJson() {
    return {
      keyStart: start,
      keyEnd: end,
      keyWeek: week,
    };
  }
}
