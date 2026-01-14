import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jup_weekly/features/checklist/domain/entities/day_checklist_entity.dart';
import 'package:jup_weekly/features/checklist/domain/entities/task_entity.dart';
import 'package:jup_weekly/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:jup_weekly/features/checklist/presentation/screens/month_screen.dart';
import 'package:jup_weekly/features/checklist/presentation/screens/weekly_grid_screen.dart';
import 'package:jup_weekly/features/checklist/presentation/widgets/empty_tasks_widget.dart';
import 'package:jup_weekly/features/checklist/presentation/widgets/task_tile.dart';
import 'package:provider/provider.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChecklistProvider>(context, listen: false).loadWeek();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ChecklistProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || provider.week == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDailyView(provider),
                const WeeklyGridScreen(), // Re-using the beautiful grid screen
              ],
            );
          },
        ),
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add, size: 28),
        elevation: 4,
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today_rounded),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Grid',
          ),
        ],
      ),
    );
  }

  // This is the content of the "Daily" tab
  Widget _buildDailyView(ChecklistProvider provider) {
    final dayIndex = provider.week!.days.indexWhere((d) => DateUtils.isSameDay(d.date, _selectedDate));
    final DayChecklistEntity? selectedDay = dayIndex != -1 ? provider.week!.days[dayIndex] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildDateSelector(provider.week!.days),
        const SizedBox(height: 16),
        _buildTaskList(selectedDay, provider),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: Theme.of(context).primaryColor, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MonthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(DayChecklistEntity? selectedDay, ChecklistProvider provider) {
    if (selectedDay == null || selectedDay.tasks.isEmpty) {
      return const Expanded(child: EmptyTasksWidget());
    }

    selectedDay.tasks.sort((a, b) => b.priority.compareTo(a.priority));

    return Expanded(
      child: ReorderableListView.builder(
        padding: EdgeInsets.zero,
        itemCount: selectedDay.tasks.length,
        itemBuilder: (context, index) {
          final task = selectedDay.tasks[index];
          return TaskTile(
            key: Key(task.id),
            task: task,
            onChanged: (_) {
              provider.onToggleTask(selectedDay.date, task.id);
            },
            onDismissed: () async {
              final confirm = await _showDeleteConfirmationDialog(context);
              if (confirm ?? false) {
                provider.onDeleteTask(selectedDay.date, task.id);
              } else {
                provider.loadWeek();
              }
            },
            onLongPress: () {
              _showEditTaskDialog(context, task, selectedDay.date);
            },
          );
        },
        onReorder: (oldIndex, newIndex) {
          provider.onReorderTask(selectedDay.date, oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildDateSelector(List<DayChecklistEntity> days) {
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = DateUtils.isSameDay(day.date, _selectedDate);
          return GestureDetector(
            onTap: () => _onDateSelected(day.date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == days.length - 1 ? 16 : 8,
              ),
              padding: const EdgeInsets.all(12),
              width: 65,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(day.date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.d().format(day.date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _showTaskBottomSheet(context);
  }

  void _showEditTaskDialog(BuildContext context, TaskEntity task, DateTime day) {
    _showTaskBottomSheet(context, task: task, day: day);
  }

  void _showTaskBottomSheet(BuildContext context, {TaskEntity? task, DateTime? day}) {
    final provider = Provider.of<ChecklistProvider>(context, listen: false);
    final isEditing = task != null;
    final date = day ?? _selectedDate;

    final TextEditingController controller = TextEditingController(text: task?.title);
    int selectedPriority = task?.priority ?? 0;
    List<DateTime> selectedDays = [date];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEditing ? 'Edit Task' : 'Add a New Task',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g., Morning workout',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!isEditing) ...[
                    const Text('Repeat on', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildWeekDaysSelector(setModalState, provider.week!.days, selectedDays),
                    const SizedBox(height: 20),
                  ],

                  const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPrioritySelector(
                        setModalState: setModalState,
                        currentPriority: selectedPriority,
                        priorityValue: 0,
                        label: 'None',
                        color: Colors.grey,
                        onSelect: () => selectedPriority = 0,
                      ),
                      _buildPrioritySelector(
                        setModalState: setModalState,
                        currentPriority: selectedPriority,
                        priorityValue: 1,
                        label: 'Medium',
                        color: Colors.amber.shade700,
                        onSelect: () => selectedPriority = 1,
                      ),
                      _buildPrioritySelector(
                        setModalState: setModalState,
                        currentPriority: selectedPriority,
                        priorityValue: 2,
                        label: 'High',
                        color: Colors.red.shade700,
                        onSelect: () => selectedPriority = 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          if (isEditing) {
                            provider.onEditTask(date, task.id, controller.text, selectedPriority);
                          } else {
                            if (selectedDays.isEmpty) {
                              return;
                            }
                            provider.onAddTask(selectedDays, controller.text, selectedPriority);
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(isEditing ? 'Save Changes' : 'Add Task',
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildWeekDaysSelector(StateSetter setModalState, List<DayChecklistEntity> weekDays, List<DateTime> selectedDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        final isSelected = selectedDays.any((selectedDay) => DateUtils.isSameDay(selectedDay, day.date));
        return GestureDetector(
          onTap: () {
            setModalState(() {
              if (isSelected) {
                selectedDays.removeWhere((d) => DateUtils.isSameDay(d, day.date));
              } else {
                selectedDays.add(day.date);
              }
            });
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            child: Text(
              DateFormat.E().format(day.date).substring(0, 1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector({
    required StateSetter setModalState,
    required int currentPriority,
    required int priorityValue,
    required String label,
    required Color color,
    required VoidCallback onSelect,
  }) {
    final isSelected = currentPriority == priorityValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            onSelect();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Task?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
