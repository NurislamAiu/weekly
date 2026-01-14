import '../repositories/checklist_repository.dart';

class EditTaskUseCase {
  final ChecklistRepository repository;

  EditTaskUseCase(this.repository);

  Future<void> call(DateTime day, String taskId, String newTitle, int priority) {
    return repository.editTask(day: day, taskId: taskId, newTitle: newTitle, priority: priority);
  }
}
