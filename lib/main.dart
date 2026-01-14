import 'package:flutter/material.dart';
import 'package:jup_weekly/core/theme/app_theme.dart';
import 'package:jup_weekly/features/checklist/data/datasources/checklist_local_data_source.dart';
import 'package:jup_weekly/features/checklist/data/datasources/checklist_local_data_source_impl.dart';
import 'package:jup_weekly/features/checklist/data/repositories/checklist_repository_impl.dart';
import 'package:jup_weekly/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/add_task_usecase.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/delete_task_usecase.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/edit_task_usecase.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/get_current_week_usecase.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/reorder_task_usecase.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/reset_week_usecase.dart';
import 'package:jup_weekly/features/checklist/domain/usecases/toggle_task_usecase.dart';
import 'package:jup_weekly/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:jup_weekly/features/checklist/presentation/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        ChecklistRepository repository =
            ChecklistRepositoryImpl(localDataSource: ChecklistLocalDataSourceImpl(sharedPreferences: sharedPreferences));
        return ChecklistProvider(
          getWeek: GetCurrentWeekUseCase(repository),
          toggleTask: ToggleTaskUseCase(repository),
          addTask: AddTaskUseCase(repository),
          deleteTask: DeleteTaskUseCase(repository),
          editTask: EditTaskUseCase(repository),
          reorderTask: ReorderTaskUseCase(repository),
          resetWeek: ResetWeekUseCase(repository),
        );
      },
      child: MaterialApp(
        title: 'Weekly Checklist',
        theme: AppTheme.theme,
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
