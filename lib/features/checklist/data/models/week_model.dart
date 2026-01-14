import '../../domain/entities/week_entity.dart';
import 'day_checklist_model.dart';

class WeekModel extends WeekEntity {
  WeekModel({
    required super.weekStart,
    required super.days,
  });

  factory WeekModel.fromJson(Map<String, dynamic> json) {
    return WeekModel(
      weekStart: DateTime.parse(json['weekStart']),
      days: (json['days'] as List)
          .map((dayJson) => DayChecklistModel.fromJson(dayJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekStart': weekStart.toIso8601String(),
      'days': days.map((day) => (day as DayChecklistModel).toJson()).toList(),
    };
  }
}
