import 'package:flutter/material.dart';
import 'package:jup_weekly/features/checklist/presentation/screens/week_screen.dart';
import 'package:jup_weekly/features/checklist/presentation/screens/weekly_grid_screen.dart';

const double desktopBreakpoint = 900.0;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          // Desktop layout: 2-панельный вид
          return const Scaffold(
            body: Row(
              children: [
                // Левая панель (40% ширины)
                Expanded(
                  flex: 4,
                  child: WeekScreen(), // Основной экран с задачами
                ),
                // Вертикальный разделитель
                VerticalDivider(width: 1, thickness: 1),
                // Правая панель (60% ширины)
                Expanded(
                  flex: 6,
                  child: WeeklyGridScreen(), // Сетка на неделю
                ),
              ],
            ),
          );
        } else {
          // Mobile layout: Используем WeekScreen с BottomNavigationBar
          return const WeekScreen();
        }
      },
    );
  }
}
