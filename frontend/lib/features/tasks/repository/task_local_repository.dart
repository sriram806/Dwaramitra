import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/task_model.dart';

class TaskLocalRepository {
  static const String _tasksKey = 'cached_tasks';

  // Save all tasks to local storage
  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskJsonList = tasks.map((task) => task.toMap()).toList();
      final tasksJson = jsonEncode(taskJsonList);
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      print('Error saving tasks to local storage: $e');
      rethrow;
    }
  }

  // Get all tasks from local storage
  Future<List<TaskModel>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson == null) {
        return [];
      }
      
      final taskJsonList = jsonDecode(tasksJson) as List;
      return taskJsonList
          .map((taskJson) => TaskModel.fromMap(taskJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading tasks from local storage: $e');
      return [];
    }
  }

  // Insert a single task
  Future<void> insertTask(TaskModel task) async {
    try {
      final tasks = await getTasks();
      
      // Remove existing task with same id if it exists
      tasks.removeWhere((t) => t.id == task.id);
      
      // Add new task
      tasks.add(task);
      
      await saveTasks(tasks);
    } catch (e) {
      print('Error inserting task to local storage: $e');
      rethrow;
    }
  }

  // Insert multiple tasks
  Future<void> insertTasks(List<TaskModel> tasksList) async {
    try {
      await saveTasks(tasksList);
    } catch (e) {
      print('Error inserting multiple tasks to local storage: $e');
      rethrow;
    }
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);
      
      if (index != -1) {
        tasks[index] = task;
        await saveTasks(tasks);
      }
    } catch (e) {
      print('Error updating task in local storage: $e');
      rethrow;
    }
  }

  // Update sync status for a specific task
  Future<void> updateRowValue(String taskId, int syncValue) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == taskId);
      
      if (index != -1) {
        final updatedTask = tasks[index].copyWith(isSynced: syncValue);
        tasks[index] = updatedTask;
        await saveTasks(tasks);
      }
    } catch (e) {
      print('Error updating task sync value in local storage: $e');
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      final tasks = await getTasks();
      tasks.removeWhere((t) => t.id == taskId);
      await saveTasks(tasks);
    } catch (e) {
      print('Error deleting task from local storage: $e');
      rethrow;
    }
  }

  // Clear all tasks
  Future<void> clearTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
    } catch (e) {
      print('Error clearing tasks from local storage: $e');
      rethrow;
    }
  }

  // Get task by id
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final tasks = await getTasks();
      return tasks.firstWhere(
        (task) => task.id == taskId,
        orElse: () => throw StateError('Task not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Get tasks by sync status
  Future<List<TaskModel>> getTasksBySyncStatus(int syncStatus) async {
    try {
      final tasks = await getTasks();
      return tasks.where((task) => task.isSynced == syncStatus).toList();
    } catch (e) {
      print('Error getting tasks by sync status from local storage: $e');
      return [];
    }
  }

  // Get unsynced tasks
  Future<List<TaskModel>> getUnsyncedTasks() async {
    try {
      final tasks = await getTasks();
      return tasks.where((task) => task.isSynced == 0).toList();
    } catch (e) {
      print('Error getting unsynced tasks from local storage: $e');
      return [];
    }
  }

  // Get tasks by user ID
  Future<List<TaskModel>> getTasksByUserId(String uid) async {
    try {
      final tasks = await getTasks();
      return tasks.where((task) => task.uid == uid).toList();
    } catch (e) {
      print('Error getting tasks by user ID from local storage: $e');
      return [];
    }
  }
}