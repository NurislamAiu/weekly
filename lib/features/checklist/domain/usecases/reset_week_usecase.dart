import '../repositories/checklist_repository.dart';

class ResetWeekUseCase {
  final ChecklistRepository repository;

  ResetWeekUseCase(this.repository);

  Future<void> call() {
    return repository.resetWeekIfNeeded();
  }
}
