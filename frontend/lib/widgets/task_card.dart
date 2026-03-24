import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final List<Task> allTasks;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.allTasks,
    this.searchQuery = '',
    required this.onTap,
    required this.onDelete,
  });

  bool get isBlocked {
    if (task.blockedById == null) return false;
    
    // Find the blocker task
    final blocker = allTasks.cast<Task?>().firstWhere(
      (t) => t?.id == task.blockedById,
      orElse: () => null,
    );

    // If blocker exists and its status is NOT "Done", then this task is blocked
    return blocker != null && blocker.status != TaskStatus.done;
  }

  @override
  Widget build(BuildContext context) {
    final blocked = isBlocked;
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: blocked ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: blocked ? Colors.grey[200] : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _HighlitText(
                        text: task.title,
                        query: searchQuery,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          decoration: task.status == TaskStatus.done 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    _StatusBadge(status: task.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.dueDate.isBefore(DateTime.now()) && task.status != TaskStatus.done
                            ? Colors.red
                            : Colors.grey[700],
                      ),
                    ),
                    if (blocked) ...[
                      const Spacer(),
                      const Icon(Icons.lock, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text(
                        'Blocked',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TaskStatus.toDo:
        color = Colors.blue;
        break;
      case TaskStatus.inProgress:
        color = Colors.orange;
        break;
      case TaskStatus.done:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HighlitText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;

  const _HighlitText({
    required this.text,
    required this.query,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: style);
    }

    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    if (matches.isEmpty) return Text(text, style: style);

    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(backgroundColor: Colors.yellow, color: Colors.black),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
