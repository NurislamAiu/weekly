import '../repositories/checklist_repository.dart';

class ReorderTaskUseCase {
  final ChecklistRepository repository;

  ReorderTaskUseCase(this.repository);

  Future<void> call(DateTime day, int oldIndex, int newIndex) {
    return repository.reorderTask(day: day, oldIndex: oldIndex, newIndex: newIndex);
  }
}
