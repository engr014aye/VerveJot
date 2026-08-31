class FolderModel {
  final int? id;
  final String name;
  final String colorHex;
  final String icon;
  final String createdAt;
  final int noteCount;

  const FolderModel({
    this.id,
    required this.name,
    required this.colorHex,
    required this.icon,
    required this.createdAt,
    this.noteCount = 0,
  });

  FolderModel copyWith({
    int? id,
    String? name,
    String? colorHex,
    String? icon,
    String? createdAt,
    int? noteCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon': icon,
      'created_at': createdAt,
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map, {int noteCount = 0}) {
    return FolderModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'Untitled',
      colorHex: map['color_hex'] as String? ?? '#10B981',
      icon: map['icon'] as String? ?? 'folder_rounded',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      noteCount: noteCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon': icon,
      'created_at': createdAt,
    };
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel.fromMap(json);
  }
}
