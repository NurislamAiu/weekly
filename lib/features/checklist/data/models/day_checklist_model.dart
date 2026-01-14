import '../../domain/entities/day_checklist_entity.dart';
import 'task_model.dart';

class DayChecklistModel extends DayChecklistEntity {
  DayChecklistModel({
    required super.date,
    required super.tasks,
  });

  factory DayChecklistModel.fromJson(Map<String, dynamic> json) {
    return DayChecklistModel(
      date: DateTime.parse(json['date']),
      tasks: (json['tasks'] as List)
          .map((taskJson) => TaskModel.fromJson(taskJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((task) => (task as TaskModel).toJson()).toList(),
    };
  }
}
