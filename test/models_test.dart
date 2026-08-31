import 'package:flutter_test/flutter_test.dart';
import 'package:vervejot/data/models/backup_data_model.dart';
import 'package:vervejot/data/models/folder_model.dart';
import 'package:vervejot/data/models/note_model.dart';
import 'package:vervejot/data/models/task_model.dart';

void main() {
  group('Model Serialization Tests', () {
    test('FolderModel toMap and fromMap', () {
      const folder = FolderModel(
        id: 1,
        name: 'Work',
        colorHex: '#10B981',
        icon: 'work_rounded',
        createdAt: '2026-09-01T00:00:00Z',
        noteCount: 5,
      );

      final map = folder.toMap();
      expect(map['name'], 'Work');
      expect(map['color_hex'], '#10B981');

      final fromMap = FolderModel.fromMap(map, noteCount: 5);
      expect(fromMap.id, 1);
      expect(fromMap.name, 'Work');
      expect(fromMap.noteCount, 5);
    });

    test('NoteModel toMap and fromMap', () {
      const note = NoteModel(
        id: 10,
        folderId: 1,
        title: 'Project Roadmap',
        content: '## Features\n- [ ] UI Motion\n- [x] SQLite DB',
        isPinned: true,
        colorHex: '#6366F1',
        createdAt: '2026-09-01T00:00:00Z',
        updatedAt: '2026-09-01T01:00:00Z',
      );

      final map = note.toMap();
      expect(map['is_pinned'], 1);
      expect(map['title'], 'Project Roadmap');

      final fromMap = NoteModel.fromMap(map);
      expect(fromMap.id, 10);
      expect(fromMap.isPinned, true);
      expect(fromMap.content, contains('SQLite DB'));
    });

    test('TaskModel toMap and fromMap', () {
      const task = TaskModel(
        id: 20,
        noteId: 10,
        title: 'Compile AAB Bundle',
        isDone: false,
        dueDate: '2026-09-02',
        createdAt: '2026-09-01T00:00:00Z',
        updatedAt: '2026-09-01T00:00:00Z',
      );

      final map = task.toMap();
      expect(map['is_done'], 0);

      final fromMap = TaskModel.fromMap(map);
      expect(fromMap.id, 20);
      expect(fromMap.isDone, false);
      expect(fromMap.title, 'Compile AAB Bundle');
    });

    test('BackupDataModel encoding and decoding', () {
      final backup = BackupDataModel(
        version: 1,
        exportedAt: '2026-09-01T00:00:00Z',
        folders: [
          const FolderModel(
            id: 1,
            name: 'Personal',
            colorHex: '#10B981',
            icon: 'person_rounded',
            createdAt: '2026-09-01T00:00:00Z',
          ),
        ],
        notes: [
          const NoteModel(
            id: 1,
            folderId: 1,
            title: 'Meeting Notes',
            content: 'Discussed architecture.',
            isPinned: false,
            createdAt: '2026-09-01T00:00:00Z',
            updatedAt: '2026-09-01T00:00:00Z',
          ),
        ],
        tasks: [
          const TaskModel(
            id: 1,
            title: 'Send follow-up email',
            isDone: true,
            createdAt: '2026-09-01T00:00:00Z',
            updatedAt: '2026-09-01T00:00:00Z',
          ),
        ],
      );

      final jsonStr = backup.encode();
      final decoded = BackupDataModel.decode(jsonStr);

      expect(decoded.version, 1);
      expect(decoded.folders.length, 1);
      expect(decoded.folders.first.name, 'Personal');
      expect(decoded.notes.length, 1);
      expect(decoded.notes.first.title, 'Meeting Notes');
      expect(decoded.tasks.length, 1);
      expect(decoded.tasks.first.isDone, true);
    });
  });
}
