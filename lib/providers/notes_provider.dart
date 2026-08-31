import 'package:flutter/foundation.dart';
import '../data/database/database_helper.dart';
import '../data/models/note_model.dart';
import '../core/services/audio_service.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<NoteModel> _allNotes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedColorFilter;
  int? _selectedFolderFilter;

  List<NoteModel> get allNotes => _filteredNotes();
  List<NoteModel> get pinnedNotes => _filteredNotes().where((n) => n.isPinned).toList();
  List<NoteModel> get unpinnedNotes => _filteredNotes().where((n) => !n.isPinned).toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedColorFilter => _selectedColorFilter;
  int? get selectedFolderFilter => _selectedFolderFilter;
  int get totalNotesCount => _allNotes.length;

  List<NoteModel> _filteredNotes() {
    return _allNotes.where((note) {
      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchTitle = note.title.toLowerCase().contains(query);
        final matchContent = note.content.toLowerCase().contains(query);
        if (!matchTitle && !matchContent) return false;
      }

      // Color filter
      if (_selectedColorFilter != null && note.colorHex != _selectedColorFilter) {
        return false;
      }

      // Folder filter
      if (_selectedFolderFilter != null && note.folderId != _selectedFolderFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allNotes = await _db.getNotes();
    } catch (_) {
      _allNotes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setColorFilter(String? colorHex) {
    if (_selectedColorFilter == colorHex) {
      _selectedColorFilter = null;
    } else {
      _selectedColorFilter = colorHex;
    }
    notifyListeners();
  }

  void setFolderFilter(int? folderId) {
    if (_selectedFolderFilter == folderId) {
      _selectedFolderFilter = null;
    } else {
      _selectedFolderFilter = folderId;
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedColorFilter = null;
    _selectedFolderFilter = null;
    notifyListeners();
  }

  Future<int> createNote(NoteModel note) async {
    final id = await _db.insertNote(note);
    await loadNotes();
    AudioService().playRustle();
    return id;
  }

  Future<void> updateNote(NoteModel note) async {
    await _db.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    await loadNotes();
    AudioService().playDelete();
  }

  Future<void> togglePin(int id) async {
    final noteIndex = _allNotes.indexWhere((n) => n.id == id);
    if (noteIndex != -1) {
      final note = _allNotes[noteIndex];
      final newPinnedState = !note.isPinned;
      await _db.togglePin(id, newPinnedState);
      await loadNotes();
      AudioService().playTap();
    }
  }

  List<NoteModel> getNotesForFolder(int folderId) {
    return _allNotes.where((n) => n.folderId == folderId).toList();
  }
}
