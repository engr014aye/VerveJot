class NoteModel {
  final int? id;
  final int? folderId;
  final String title;
  final String content;
  final bool isPinned;
  final String? colorHex;
  final String createdAt;
  final String updatedAt;

  const NoteModel({
    this.id,
    this.folderId,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    int? id,
    int? folderId,
    String? title,
    String? content,
    bool? isPinned,
    String? colorHex,
    String? createdAt,
    String? updatedAt,
    bool clearFolder = false,
  }) {
    return NoteModel(
      id: id ?? this.id,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'folder_id': folderId,
      'title': title,
      'content': content,
      'is_pinned': isPinned ? 1 : 0,
      'color_hex': colorHex,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      folderId: map['folder_id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      colorHex: map['color_hex'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folder_id': folderId,
      'title': title,
      'content': content,
      'is_pinned': isPinned ? 1 : 0,
      'color_hex': colorHex,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel.fromMap(json);
  }
}
