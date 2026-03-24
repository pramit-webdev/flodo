import 'dart:convert';

enum TaskStatus {
  toDo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  final String label;
  const TaskStatus(this.label);

  static TaskStatus fromString(String status) {
    return TaskStatus.values.firstWhere(
      (e) => e.label == status,
      orElse: () => TaskStatus.toDo,
    );
  }
}

class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedById;
  final int orderIndex;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.toDo,
    this.blockedById,
    this.orderIndex = 0,
    this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedById,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById ?? this.blockedById,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status.label,
      'blocked_by_id': blockedById,
      'order_index': orderIndex,
    };
  }

  factory Task.fromJson(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['due_date']),
      status: TaskStatus.fromString(map['status']),
      blockedById: map['blocked_by_id'],
      orderIndex: map['order_index'] ?? 0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
