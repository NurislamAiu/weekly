import '../entities/week_entity.dart';
import '../repositories/checklist_repository.dart';

class GetCurrentWeekUseCase {
  final ChecklistRepository repository;

  GetCurrentWeekUseCase(this.repository);

  Future<WeekEntity> call() {
    return repository.getCurrentWeek();
  }
}
