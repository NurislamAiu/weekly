import '../models/week_model.dart';

abstract class ChecklistLocalDataSource {
  Future<WeekModel?> getWeek();
  Future<void> saveWeek(WeekModel week);
}
