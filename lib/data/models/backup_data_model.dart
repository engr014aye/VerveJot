import 'dart:convert';
import 'folder_model.dart';
import 'note_model.dart';
import 'task_model.dart';

class BackupDataModel {
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
    final folderList = (json['folders'] as List<dynamic>? ?? [])
        .map((e) => FolderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final noteList = (json['notes'] as List<dynamic>? ?? [])
        .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final taskList = (json['tasks'] as List<dynamic>? ?? [])
        .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return BackupDataModel(
      version: json['version'] as int? ?? 1,
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
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload format.');
    }
    return BackupDataModel.fromJson(decoded);
  }
}
