import 'dart:convert';
import 'folder_model.dart';
import 'note_model.dart';
import 'task_model.dart';

class BackupDataModel {
  static const int maxPayloadBytes = 20 * 1024 * 1024; // 20 MB safety limit

  final int version;
  final String exportedAt;
  final List<FolderModel> folders;
  final List<NoteModel> notes;
  final List<TaskModel> tasks;

  const BackupDataModel({
    this.version = 1,
    required this.exportedAt,
    required this.folders,
    required this.notes,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'app': 'VerveJot',
      'version': version,
      'exported_at': exportedAt,
      'folders': folders.map((f) => f.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  factory BackupDataModel.fromJson(Map<String, dynamic> json) {
    final List<FolderModel> folderList = [];
    if (json['folders'] is List) {
      for (final item in (json['folders'] as List)) {
        if (item is Map) {
          try {
            folderList.add(FolderModel.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {
            // Skip malformed folder record defensively
          }
        }
      }
    }

    final List<NoteModel> noteList = [];
    if (json['notes'] is List) {
      for (final item in (json['notes'] as List)) {
        if (item is Map) {
          try {
            noteList.add(NoteModel.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {
            // Skip malformed note record defensively
          }
        }
      }
    }

    final List<TaskModel> taskList = [];
    if (json['tasks'] is List) {
      for (final item in (json['tasks'] as List)) {
        if (item is Map) {
          try {
            taskList.add(TaskModel.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {
            // Skip malformed task record defensively
          }
        }
      }
    }

    return BackupDataModel(
      version: (json['version'] as num?)?.toInt() ?? 1,
      exportedAt: json['exported_at'] as String? ?? DateTime.now().toIso8601String(),
      folders: folderList,
      notes: noteList,
      tasks: taskList,
    );
  }

  String encode() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory BackupDataModel.decode(String rawJson) {
    if (rawJson.length > maxPayloadBytes) {
      throw const FormatException('Backup payload exceeds the 20MB safety limit.');
    }
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload format: root must be a JSON object.');
    }
    return BackupDataModel.fromJson(decoded);
  }
}
