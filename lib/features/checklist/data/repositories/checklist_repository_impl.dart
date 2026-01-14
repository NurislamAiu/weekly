import 'package:jup_weekly/features/checklist/data/models/day_checklist_model.dart';
import 'package:jup_weekly/features/checklist/data/models/task_model.dart';
import 'package:jup_weekly/features/checklist/data/models/week_model.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/week_entity.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../datasources/checklist_local_data_source.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistLocalDataSource localDataSource;
  final Uuid uuid;

  ChecklistRepositoryImpl({required this.localDataSource}) : uuid = const Uuid();

  @override
  Future<WeekEntity> getCurrentWeek() async {
    final cachedWeek = await localDataSource.getWeek();
    if (cachedWeek != null && _isCurrentWeek(cachedWeek.weekStart)) {
      return cachedWeek;
    } else {
      final newWeek = _createNewWeek();
      await localDataSource.saveWeek(newWeek);
      return newWeek;
    }
  }

  @override
  Future<void> addTask({required List<DateTime> days, required String taskTitle, int priority = 0}) async {
    final week = await localDataSource.getWeek();
    if (week == null) return;

    var updatedDays = List<DayChecklistModel>.from(week.days);
    bool changed = false;

    for (var day in days) {
      final dayIndex = _findDayIndex(week, day);
      if (dayIndex != -1) {
        final newTask = TaskModel(id: uuid.v4(), title: taskTitle, isCompleted: false, priority: priority);
        final updatedTasks = List<TaskModel>.from(updatedDays[dayIndex].tasks)..add(newTask);
        updatedDays[dayIndex] = DayChecklistModel(date: updatedDays[dayIndex].date, tasks: updatedTasks);
        changed = true;
      }
    }

    if (changed) {
      final updatedWeek = WeekModel(weekStart: week.weekStart, days: updatedDays);
      await localDataSource.saveWeek(updatedWeek);
    }
  }
  
  // ... (остальные методы без изменений)
  @override
  Future<void> deleteTask({required DateTime day, required String taskId}) async {
    final week = await localDataSource.getWeek();
    if (week == null) return;
    final dayIndex = _findDayIndex(week, day);
    if (dayIndex == -1) return;

    final updatedTasks = List<TaskModel>.from(week.days[dayIndex].tasks)..removeWhere((task) => task.id == taskId);
    await _saveUpdatedDay(week, dayIndex, updatedTasks);
  }

  @override
  Future<void> editTask({required DateTime day, required String taskId, required String newTitle, required int priority}) async {
    final week = await localDataSource.getWeek();
    if (week == null) return;
    final dayIndex = _findDayIndex(week, day);
    if (dayIndex == -1) return;

    final taskIndex = week.days[dayIndex].tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final originalTask = week.days[dayIndex].tasks[taskIndex] as TaskModel;
    final updatedTask = TaskModel(id: originalTask.id, title: newTitle, isCompleted: originalTask.isCompleted, priority: priority);

    final updatedTasks = List<TaskModel>.from(week.days[dayIndex].tasks);
    updatedTasks[taskIndex] = updatedTask;
    await _saveUpdatedDay(week, dayIndex, updatedTasks);
  }

  @override
  Future<void> reorderTask({required DateTime day, required int oldIndex, required int newIndex}) async {
    final week = await localDataSource.getWeek();
    if (week == null) return;
    final dayIndex = _findDayIndex(week, day);
    if (dayIndex == -1) return;

    final tasks = List<TaskModel>.from(week.days[dayIndex].tasks);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    await _saveUpdatedDay(week, dayIndex, tasks);
  }
  
  @override
  Future<void> toggleTask({required DateTime day, required String taskId}) async {
    final week = await localDataSource.getWeek();
    if (week == null) return;
    final dayIndex = _findDayIndex(week, day);
    if (dayIndex == -1) return;

    final taskIndex = week.days[dayIndex].tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final originalTask = week.days[dayIndex].tasks[taskIndex] as TaskModel;
    final updatedTask = TaskModel(id: originalTask.id, title: originalTask.title, isCompleted: !originalTask.isCompleted, priority: originalTask.priority);

    final updatedTasks = List<TaskModel>.from(week.days[dayIndex].tasks);
    updatedTasks[taskIndex] = updatedTask;
    await _saveUpdatedDay(week, dayIndex, updatedTasks);
  }

  @override
  Future<void> resetWeekIfNeeded() async {
    final cachedWeek = await localDataSource.getWeek();
    if (cachedWeek == null || !_isCurrentWeek(cachedWeek.weekStart)) {
      final newWeek = _createNewWeek();
      await localDataSource.saveWeek(newWeek);
    }
  }

  int _findDayIndex(WeekModel week, DateTime day) {
    return week.days.indexWhere((d) => d.date.day == day.day && d.date.month == day.month && d.date.year == day.year);
  }

  Future<void> _saveUpdatedDay(WeekModel week, int dayIndex, List<TaskModel> tasks) async {
    final updatedDay = DayChecklistModel(date: week.days[dayIndex].date, tasks: tasks);
    final updatedDays = List<DayChecklistModel>.from(week.days);
    updatedDays[dayIndex] = updatedDay;
    final updatedWeek = WeekModel(weekStart: week.weekStart, days: updatedDays);
    await localDataSource.saveWeek(updatedWeek);
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return weekStart.year == startOfWeek.year &&
        weekStart.month == startOfWeek.month &&
        weekStart.day == startOfWeek.day;
  }

  WeekModel _createNewWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return DayChecklistModel(date: date, tasks: []);
    });
    return WeekModel(weekStart: startOfWeek, days: days);
  }
}
