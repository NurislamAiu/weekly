import 'task_entity.dart';

class DayChecklistEntity {
  final DateTime date;
  final List<TaskEntity> tasks;

  DayChecklistEntity({
    required this.date,
    required this.tasks,
  });
}
