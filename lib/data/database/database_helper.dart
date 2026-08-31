import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/folder_model.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../models/backup_data_model.dart';
import 'tables.dart';

class DatabaseHelper {
  static const String _databaseName = 'vervejot.db';
  static const int _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(Tables.createFoldersTable);
    await db.execute(Tables.createNotesTable);
    await db.execute(Tables.createTasksTable);
    await db.execute(Tables.createNotesIndex);
    await db.execute(Tables.createTasksIndex);

    // Insert default starter folders
    final now = DateTime.now().toIso8601String();
    await db.insert(Tables.folders, {
      Tables.folderName: 'Personal',
      Tables.folderColorHex: '#10B981',
      Tables.folderIcon: 'person_rounded',
      Tables.folderCreatedAt: now,
    });
    await db.insert(Tables.folders, {
      Tables.folderName: 'Work & Projects',
      Tables.folderColorHex: '#6366F1',
      Tables.folderIcon: 'work_rounded',
      Tables.folderCreatedAt: now,
    });
    await db.insert(Tables.folders, {
      Tables.folderName: 'Ideas & Drafts',
      Tables.folderColorHex: '#F59E0B',
      Tables.folderIcon: 'lightbulb_rounded',
      Tables.folderCreatedAt: now,
    });
  }

  // ==================== FOLDERS ====================

  Future<int> insertFolder(FolderModel folder) async {
    final db = await database;
    return await db.insert(Tables.folders, folder.toMap());
  }

  Future<int> updateFolder(FolderModel folder) async {
    final db = await database;
    return await db.update(
      Tables.folders,
      folder.toMap(),
      where: '${Tables.folderId} = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    // Notes assigned to this folder will have folder_id set to NULL due to ON DELETE SET NULL
    return await db.delete(
      Tables.folders,
      where: '${Tables.folderId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<FolderModel>> getFolders() async {
    final db = await database;
    const query = '''
      SELECT f.*, COUNT(n.id) as note_count
      FROM ${Tables.folders} f
      LEFT JOIN ${Tables.notes} n ON f.id = n.folder_id
      GROUP BY f.id
      ORDER BY f.id ASC
    ''';
    final result = await db.rawQuery(query);
    return result.map((map) {
      final count = (map['note_count'] as num?)?.toInt() ?? 0;
      return FolderModel.fromMap(map, noteCount: count);
    }).toList();
  }

  Future<FolderModel?> getFolderById(int id) async {
    final db = await database;
    final result = await db.query(
      Tables.folders,
      where: '${Tables.folderId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return FolderModel.fromMap(result.first);
  }

  // ==================== NOTES ====================

  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert(Tables.notes, note.toMap());
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      Tables.notes,
      note.toMap(),
      where: '${Tables.noteId} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      Tables.notes,
      where: '${Tables.noteId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> togglePin(int id, bool isPinned) async {
    final db = await database;
    return await db.update(
      Tables.notes,
      {
        Tables.noteIsPinned: isPinned ? 1 : 0,
        Tables.noteUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${Tables.noteId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<NoteModel>> getNotes({
    int? folderId,
    bool? isPinned,
    String? searchQuery,
  }) async {
    final db = await database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (folderId != null) {
      whereClauses.add('${Tables.noteFolderId} = ?');
      whereArgs.add(folderId);
    }

    if (isPinned != null) {
      whereClauses.add('${Tables.noteIsPinned} = ?');
      whereArgs.add(isPinned ? 1 : 0);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(${Tables.noteTitle} LIKE ? OR ${Tables.noteContent} LIKE ?)');
      whereArgs.add('%${searchQuery.trim()}%');
      whereArgs.add('%${searchQuery.trim()}%');
    }

    final String? where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final result = await db.query(
      Tables.notes,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${Tables.noteIsPinned} DESC, ${Tables.noteUpdatedAt} DESC',
    );

    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  Future<NoteModel?> getNoteById(int id) async {
    final db = await database;
    final result = await db.query(
      Tables.notes,
      where: '${Tables.noteId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return NoteModel.fromMap(result.first);
  }

  // ==================== TASKS ====================

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert(Tables.tasks, task.toMap());
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      Tables.tasks,
      task.toMap(),
      where: '${Tables.taskId} = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      Tables.tasks,
      where: '${Tables.taskId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleTaskDone(int id, bool isDone) async {
    final db = await database;
    return await db.update(
      Tables.tasks,
      {
        Tables.taskIsDone: isDone ? 1 : 0,
        Tables.taskUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${Tables.taskId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<TaskModel>> getTasks({
    int? noteId,
    bool? isDone,
    String? searchQuery,
  }) async {
    final db = await database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (noteId != null) {
      whereClauses.add('${Tables.taskNoteId} = ?');
      whereArgs.add(noteId);
    }

    if (isDone != null) {
      whereClauses.add('${Tables.taskIsDone} = ?');
      whereArgs.add(isDone ? 1 : 0);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('${Tables.taskTitle} LIKE ?');
      whereArgs.add('%${searchQuery.trim()}%');
    }

    final String? where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final result = await db.query(
      Tables.tasks,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '${Tables.taskIsDone} ASC, ${Tables.taskCreatedAt} DESC',
    );

    return result.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<int> clearCompletedTasks() async {
    final db = await database;
    return await db.delete(
      Tables.tasks,
      where: '${Tables.taskIsDone} = 1',
    );
  }

  // ==================== BACKUP & RESTORE ====================

  Future<BackupDataModel> exportAllData() async {
    final db = await database;

    final folderMaps = await db.query(Tables.folders);
    final noteMaps = await db.query(Tables.notes);
    final taskMaps = await db.query(Tables.tasks);

    final folders = folderMaps.map((e) => FolderModel.fromMap(e)).toList();
    final notes = noteMaps.map((e) => NoteModel.fromMap(e)).toList();
    final tasks = taskMaps.map((e) => TaskModel.fromMap(e)).toList();

    return BackupDataModel(
      version: 1,
      exportedAt: DateTime.now().toIso8601String(),
      folders: folders,
      notes: notes,
      tasks: tasks,
    );
  }

  Future<void> importAllData(
    BackupDataModel backup, {
    bool replaceExisting = false,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      if (replaceExisting) {
        await txn.delete(Tables.tasks);
        await txn.delete(Tables.notes);
        await txn.delete(Tables.folders);
      }

      // Map old folder IDs to new folder IDs if merging without replacing
      final Map<int, int> folderIdMapping = {};

      for (final folder in backup.folders) {
        final map = folder.toMap();
        if (!replaceExisting) {
          map.remove('id');
        }
        final newId = await txn.insert(
          Tables.folders,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (folder.id != null) {
          folderIdMapping[folder.id!] = newId;
        }
      }

      final Map<int, int> noteIdMapping = {};

      for (final note in backup.notes) {
        final map = note.toMap();
        if (!replaceExisting) {
          map.remove('id');
          if (note.folderId != null && folderIdMapping.containsKey(note.folderId)) {
            map['folder_id'] = folderIdMapping[note.folderId];
          }
        }
        final newId = await txn.insert(
          Tables.notes,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (note.id != null) {
          noteIdMapping[note.id!] = newId;
        }
      }

      for (final task in backup.tasks) {
        final map = task.toMap();
        if (!replaceExisting) {
          map.remove('id');
          if (task.noteId != null && noteIdMapping.containsKey(task.noteId)) {
            map['note_id'] = noteIdMapping[task.noteId];
          }
        }
        await txn.insert(
          Tables.tasks,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
