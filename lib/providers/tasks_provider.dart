import 'package:flutter/foundation.dart';
import '../data/database/database_helper.dart';
import '../data/models/task_model.dart';
import '../core/services/audio_service.dart';

enum TaskFilterMode { all, pending, completed }

class TasksProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  TaskFilterMode _filterMode = TaskFilterMode.all;
  String _searchQuery = '';

  List<TaskModel> get tasks => _filteredTasks();
  List<TaskModel> get allTasksRaw => _allTasks;
  bool get isLoading => _isLoading;
  TaskFilterMode get filterMode => _filterMode;
  String get searchQuery => _searchQuery;

  int get totalCount => _allTasks.length;
  int get completedCount => _allTasks.where((t) => t.isDone).length;
  int get pendingCount => _allTasks.where((t) => !t.isDone).length;

  double get completionPercentage {
    if (_allTasks.isEmpty) return 0.0;
    return completedCount / totalCount;
  }

  List<TaskModel> _filteredTasks() {
    return _allTasks.where((task) {
      if (_searchQuery.trim().isNotEmpty) {
        if (!task.title.toLowerCase().contains(_searchQuery.trim().toLowerCase())) {
          return false;
        }
      }

      switch (_filterMode) {
        case TaskFilterMode.all:
          return true;
        case TaskFilterMode.pending:
          return !task.isDone;
        case TaskFilterMode.completed:
          return task.isDone;
      }
    }).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTasks = await _db.getTasks();
    } catch (_) {
      _allTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterMode(TaskFilterMode mode) {
    if (_filterMode != mode) {
      _filterMode = mode;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<int> createTask({
    required String title,
    int? noteId,
    String? dueDate,
  }) async {
    final now = DateTime.now().toIso8601String();
    final task = TaskModel(
      noteId: noteId,
      title: title.trim(),
      isDone: false,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _db.insertTask(task);
    await loadTasks();
    AudioService().playTap();
    return id;
  }

  Future<void> updateTask(TaskModel task) async {
    await _db.updateTask(task.copyWith(updatedAt: DateTime.now().toIso8601String()));
    await loadTasks();
  }

  Future<void> toggleTask(int id, bool isDone) async {
    await _db.toggleTaskDone(id, isDone);
    if (isDone) {
      AudioService().playChime();
    } else {
      AudioService().playTap();
    }
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    AudioService().playDelete();
    await loadTasks();
  }

  Future<void> clearCompleted() async {
    await _db.clearCompletedTasks();
    AudioService().playDelete();
    await loadTasks();
  }
}
