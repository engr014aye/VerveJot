class TaskModel {
  final int? id;
  final int? noteId;
  final String title;
  final bool isDone;
  final String? dueDate;
  final String createdAt;
  final String updatedAt;

  const TaskModel({
    this.id,
    this.noteId,
    required this.title,
    this.isDone = false,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskModel copyWith({
    int? id,
    int? noteId,
    String? title,
    bool? isDone,
    String? dueDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'note_id': noteId,
      'title': title,
      'is_done': isDone ? 1 : 0,
      'due_date': dueDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      noteId: map['note_id'] as int?,
      title: map['title'] as String? ?? '',
      isDone: (map['is_done'] as int? ?? 0) == 1,
      dueDate: map['due_date'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note_id': noteId,
      'title': title,
      'is_done': isDone ? 1 : 0,
      'due_date': dueDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel.fromMap(json);
  }
}
