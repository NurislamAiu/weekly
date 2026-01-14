import 'day_checklist_entity.dart';

class WeekEntity {
  final DateTime weekStart;
  final List<DayChecklistEntity> days;

  WeekEntity({
    required this.weekStart,
    required this.days,
  });
}
