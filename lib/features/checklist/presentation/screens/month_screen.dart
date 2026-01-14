import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jup_weekly/features/checklist/domain/entities/day_checklist_entity.dart';
import 'package:jup_weekly/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:jup_weekly/features/checklist/presentation/widgets/task_tile.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);
    final dayIndex = provider.week?.days.indexWhere((d) => isSameDay(d.date, _selectedDay)) ?? -1;
    final DayChecklistEntity? selectedDayTasks = dayIndex != -1 ? provider.week!.days[dayIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Overview'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(
            child: selectedDayTasks != null
                ? ListView.builder(
                    itemCount: selectedDayTasks.tasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedDayTasks.tasks[index];
                      return TaskTile(
                        task: task,
                        onChanged: (_) {
                          provider.onToggleTask(selectedDayTasks.date, task.id);
                        },
                        onDismissed: () {
                          provider.onDeleteTask(selectedDayTasks.date, task.id);
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Select a day to see tasks',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Card _buildTableCalendar() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
      ),
    );
  }
}
