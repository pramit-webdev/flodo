import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

// API Configuration - User should change this to their deployed backend URL
const String baseUrl = 'https://flodo-backend.onrender.com';

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks({String? status, String? search}) async {
    final queryParams = <String, String>{};
    if (status != null && status != 'All') queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Task.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      // Return empty list on error for now, or rethrow
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTasks());
  }

  Future<void> filter(String? status, String? search) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTasks(status: status, search: search));
  }

  Future<void> createTask(Task task) async {
    final uri = Uri.parse('$baseUrl/tasks');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );
      if (response.statusCode == 200) {
        await refresh();
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) return;
    final uri = Uri.parse('$baseUrl/tasks/${task.id}');
    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );
      if (response.statusCode == 200) {
        await refresh();
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    final uri = Uri.parse('$baseUrl/tasks/$id');
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        await refresh();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update order for drag and drop (stretch goal)
  Future<void> updateTasksOrder(List<Task> reorderedTasks) async {
    // Optimistic UI update
    final previousState = state;
    state = AsyncValue.data(reorderedTasks);

    try {
      // In a real app, we might want a bulk update endpoint
      // For now, we'll update each task's order_index if changed
      for (int i = 0; i < reorderedTasks.length; i++) {
        final task = reorderedTasks[i];
        if (task.orderIndex != i) {
          await updateTask(task.copyWith(orderIndex: i));
        }
      }
    } catch (e) {
      state = previousState; // Revert on failure
      rethrow;
    }
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});

// Draft Provider for local persistence
final draftProvider = StateNotifierProvider<DraftNotifier, Map<String, String>>((ref) {
  return DraftNotifier();
});

class DraftNotifier extends StateNotifier<Map<String, String>> {
  DraftNotifier() : super({}) {
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString('task_drafts');
    if (draftJson != null) {
      state = Map<String, String>.from(json.decode(draftJson));
    }
  }

  Future<void> saveDraft(String key, String value) async {
    state = {...state, key: value};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('task_drafts', json.encode(state));
  }

  Future<void> clearDraft() async {
    state = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('task_drafts');
  }
}

// Search and Filter states
final filterStatusProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');
