import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/week_model.dart';
import 'checklist_local_data_source.dart';

const CACHED_WEEK = 'CACHED_WEEK';

class ChecklistLocalDataSourceImpl implements ChecklistLocalDataSource {
  final SharedPreferences sharedPreferences;

  ChecklistLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<WeekModel?> getWeek() {
    final jsonString = sharedPreferences.getString(CACHED_WEEK);
    if (jsonString != null) {
      return Future.value(WeekModel.fromJson(json.decode(jsonString)));
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> saveWeek(WeekModel week) {
    return sharedPreferences.setString(
      CACHED_WEEK,
      json.encode(week.toJson()),
    );
  }
}
