import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? initialTask;
  const TaskFormScreen({super.key, this.initialTask});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskStatus _status;
  String? _blockedById;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _status = task?.status ?? TaskStatus.toDo;
    _blockedById = task?.blockedById;

    // Load drafts if this is a new task
    if (task == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final drafts = ref.read(draftProvider);
        if (drafts.containsKey('title')) _titleController.text = drafts['title']!;
        if (drafts.containsKey('description')) _descriptionController.text = drafts['description']!;
      });
    }

    // Listener to save drafts
    _titleController.addListener(() {
      if (widget.initialTask == null) {
        ref.read(draftProvider.notifier).saveDraft('title', _titleController.text);
      }
    });
    _descriptionController.addListener(() {
      if (widget.initialTask == null) {
        ref.read(draftProvider.notifier).saveDraft('description', _descriptionController.text);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final task = Task(
      id: widget.initialTask?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      status: _status,
      blockedById: _blockedById,
      orderIndex: widget.initialTask?.orderIndex ?? 0,
    );

    try {
      if (widget.initialTask == null) {
        await ref.read(taskProvider.notifier).createTask(task);
        // Clear drafts on successful creation
        ref.read(draftProvider.notifier).clearDraft();
      } else {
        await ref.read(taskProvider.notifier).updateTask(task);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskProvider);
    final availableTasks = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) => t.id != widget.initialTask?.id).toList(),
      orElse: () => <Task>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTask == null ? 'New Task' : 'Edit Task'),
        actions: [
          if (widget.initialTask != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(taskProvider.notifier).deleteTask(widget.initialTask!.id!);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Please enter a description' : null,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('MMMM dd, yyyy').format(_dueDate)),
              trailing: const Icon(Icons.calendar_month),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: _isSaving ? null : () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.task_alt),
              ),
              items: TaskStatus.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.label));
              }).toList(),
              onChanged: _isSaving ? null : (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String?>(
              value: _blockedById,
              decoration: const InputDecoration(
                labelText: 'Blocked By (Optional)',
                prefixIcon: Icon(Icons.lock),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...availableTasks.map((t) {
                  return DropdownMenuItem(value: t.id, child: Text(t.title));
                }),
              ],
              onChanged: _isSaving ? null : (v) => setState(() => _blockedById = v),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 12),
                      Text('Saving...'),
                    ],
                  )
                : const Text('Save Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
