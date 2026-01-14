import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jup_weekly/features/checklist/domain/entities/task_entity.dart';
import 'package:jup_weekly/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:jup_weekly/features/checklist/presentation/widgets/custom_checkbox.dart';
import 'package:jup_weekly/features/checklist/presentation/widgets/empty_tasks_widget.dart';
import 'package:provider/provider.dart';

class WeeklyGridScreen extends StatelessWidget {
  const WeeklyGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Grid'),
        centerTitle: false,
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.week == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final week = provider.week!;
          final allTasks =
              week.days.expand((day) => day.tasks).toList();
          
          final uniqueTasks = <String, TaskEntity>{};
          for (var task in allTasks) {
            uniqueTasks.putIfAbsent(task.title, () => task);
          }
          final sortedUniqueTasks = uniqueTasks.values.toList()
            ..sort((a, b) => b.priority.compareTo(a.priority));

          if (sortedUniqueTasks.isEmpty) {
            return const EmptyTasksWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskTitlesColumn(context, sortedUniqueTasks),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildDaysGrid(context, provider, week.days, sortedUniqueTasks),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskTitlesColumn(BuildContext context, List<TaskEntity> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          width: 150,
          alignment: Alignment.centerLeft,
          child: Text(
            'Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...tasks.map((task) => _buildTaskTitleCell(context, task)),
      ],
    );
  }

  Widget _buildTaskTitleCell(BuildContext context, TaskEntity task) {
    Color getPriorityColor() {
      switch (task.priority) {
        case 1: return Colors.amber.shade700;
        case 2: return Colors.red.shade700;
        default: return Colors.transparent;
      }
    }

    return Container(
      height: 60,
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 5,
            height: double.infinity,
            decoration: BoxDecoration(
              color: getPriorityColor(),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context, ChecklistProvider provider, List<dynamic> days, List<TaskEntity> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayHeaderRow(context, days),
        ...tasks.map((task) => _buildTaskCheckboxRow(provider, days, task)),
      ],
    );
  }

  Widget _buildDayHeaderRow(BuildContext context, List<dynamic> days) {
    return Row(
      children: days.map((day) {
        return Container(
          height: 60,
          width: 60,
          child: Center(
            child: Text(
              DateFormat.E().format(day.date),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCheckboxRow(ChecklistProvider provider, List<dynamic> days, TaskEntity uniqueTask) {
    return Row(
      children: days.map((day) {
        TaskEntity? task;
        try {
          task = day.tasks.firstWhere((t) => t.title == uniqueTask.title);
        } catch (e) {
          task = null;
        }

        return Container(
          height: 60,
          width: 60,
          child: Center(
            child: task == null
                ? Container()
                : CustomCheckbox(
                    isChecked: task.isCompleted,
                    onChanged: (_) {
                      provider.onToggleTask(day.date, task!.id);
                    },
                  ),
          ),
        );
      }).toList(),
    );
  }
}
