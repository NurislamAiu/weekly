import 'package:flutter/foundation.dart';
import '../../domain/entities/week_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/edit_task_usecase.dart';
import '../../domain/usecases/get_current_week_usecase.dart';
import '../../domain/usecases/reorder_task_usecase.dart';
import '../../domain/usecases/reset_week_usecase.dart';
import '../../domain/usecases/toggle_task_usecase.dart';

class ChecklistProvider extends ChangeNotifier {
  final GetCurrentWeekUseCase getWeek;
  final ToggleTaskUseCase toggleTask;
  final AddTaskUseCase addTask;
  final DeleteTaskUseCase deleteTask;
  final EditTaskUseCase editTask;
  final ReorderTaskUseCase reorderTask;
  final ResetWeekUseCase resetWeek;

  ChecklistProvider({
    required this.getWeek,
    required this.toggleTask,
    required this.addTask,
    required this.deleteTask,
    required this.editTask,
    required this.reorderTask,
    required this.resetWeek,
  });

  WeekEntity? week;
  bool isLoading = false;

  Future<void> loadWeek() async {
    if (week == null) {
      isLoading = true;
      notifyListeners();
    }
    week = await getWeek();
    isLoading = false;
    notifyListeners();
  }

  void onAddTask(List<DateTime> days, String taskTitle, int priority) async {
    await addTask(days, taskTitle, priority);
    loadWeek();
  }

  void onToggleTask(DateTime day, String taskId) async {
    await toggleTask(day, taskId);
    loadWeek();
  }

  void onDeleteTask(DateTime day, String taskId) async {
    await deleteTask(day, taskId);
    loadWeek();
  }

  void onEditTask(DateTime day, String taskId, String newTitle, int priority) async {
    await editTask(day, taskId, newTitle, priority);
    loadWeek();
  }

  void onReorderTask(DateTime day, int oldIndex, int newIndex) async {
    await reorderTask(day, oldIndex, newIndex);
    loadWeek();
  }
}
