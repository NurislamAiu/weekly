class TaskEntity {
  final String id;
  final String title;
  final bool isCompleted;
  final int priority; // 0: None, 1: Medium, 2: High

  TaskEntity({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.priority = 0,
  });
}
