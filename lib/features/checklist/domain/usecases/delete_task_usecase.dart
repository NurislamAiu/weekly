import '../repositories/checklist_repository.dart';

class DeleteTaskUseCase {
  final ChecklistRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(DateTime day, String taskId) {
    return repository.deleteTask(day: day, taskId: taskId);
  }
}
