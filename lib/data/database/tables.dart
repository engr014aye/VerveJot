class Tables {
  Tables._();

  static const String folders = 'folders';
  static const String notes = 'notes';
  static const String tasks = 'tasks';

  // Folder Columns
  static const String folderId = 'id';
  static const String folderName = 'name';
  static const String folderColorHex = 'color_hex';
  static const String folderIcon = 'icon';
  static const String folderCreatedAt = 'created_at';

  // Note Columns
  static const String noteId = 'id';
  static const String noteFolderId = 'folder_id';
  static const String noteTitle = 'title';
  static const String noteContent = 'content';
  static const String noteIsPinned = 'is_pinned';
  static const String noteColorHex = 'color_hex';
  static const String noteCreatedAt = 'created_at';
  static const String noteUpdatedAt = 'updated_at';

  // Task Columns
  static const String taskId = 'id';
  static const String taskNoteId = 'note_id';
  static const String taskTitle = 'title';
  static const String taskIsDone = 'is_done';
  static const String taskDueDate = 'due_date';
  static const String taskCreatedAt = 'created_at';
  static const String taskUpdatedAt = 'updated_at';

  static const String createFoldersTable = '''
    CREATE TABLE $folders (
      $folderId INTEGER PRIMARY KEY AUTOINCREMENT,
      $folderName TEXT NOT NULL,
      $folderColorHex TEXT NOT NULL,
      $folderIcon TEXT NOT NULL,
      $folderCreatedAt TEXT NOT NULL
    );
  ''';

  static const String createNotesTable = '''
    CREATE TABLE $notes (
      $noteId INTEGER PRIMARY KEY AUTOINCREMENT,
      $noteFolderId INTEGER,
      $noteTitle TEXT NOT NULL,
      $noteContent TEXT NOT NULL,
      $noteIsPinned INTEGER DEFAULT 0,
      $noteColorHex TEXT,
      $noteCreatedAt TEXT NOT NULL,
      $noteUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($noteFolderId) REFERENCES $folders ($folderId) ON DELETE SET NULL
    );
  ''';

  static const String createTasksTable = '''
    CREATE TABLE $tasks (
      $taskId INTEGER PRIMARY KEY AUTOINCREMENT,
      $taskNoteId INTEGER,
      $taskTitle TEXT NOT NULL,
      $taskIsDone INTEGER DEFAULT 0,
      $taskDueDate TEXT,
      $taskCreatedAt TEXT NOT NULL,
      $taskUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($taskNoteId) REFERENCES $notes ($noteId) ON DELETE CASCADE
    );
  ''';

  static const String createNotesIndex = '''
    CREATE INDEX idx_notes_folder_pinned ON $notes ($noteFolderId, $noteIsPinned, $noteUpdatedAt);
  ''';

  static const String createTasksIndex = '''
    CREATE INDEX idx_tasks_done_due ON $tasks ($taskIsDone, $taskDueDate);
  ''';
}
