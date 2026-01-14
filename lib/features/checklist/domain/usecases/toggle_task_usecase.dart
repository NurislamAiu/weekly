import '../repositories/checklist_repository.dart';

class ToggleTaskUseCase {
  final ChecklistRepository repository;

  ToggleTaskUseCase(this.repository);

  Future<void> call(DateTime day, String taskId) {
    return repository.toggleTask(day: day, taskId: taskId);
  }
}
