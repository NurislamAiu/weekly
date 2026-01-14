import '../entities/week_entity.dart';

abstract class ChecklistRepository {
  Future<WeekEntity> getCurrentWeek();
  Future<void> addTask({required List<DateTime> days, required String taskTitle, required int priority});
  Future<void> toggleTask({required DateTime day, required String taskId});
  Future<void> deleteTask({required DateTime day, required String taskId});
  Future<void> editTask({required DateTime day, required String taskId, required String newTitle, required int priority});
  Future<void> reorderTask({required DateTime day, required int oldIndex, required int newIndex});
  Future<void> resetWeekIfNeeded();
}
