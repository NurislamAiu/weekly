import '../repositories/checklist_repository.dart';

class AddTaskUseCase {
  final ChecklistRepository repository;

  AddTaskUseCase(this.repository);

  Future<void> call(List<DateTime> days, String taskTitle, int priority) {
    return repository.addTask(days: days, taskTitle: taskTitle, priority: priority);
  }
}
