import 'package:flutter/foundation.dart';
import '../core/services/audio_service.dart';
import '../core/services/preferences_service.dart';
import '../data/database/database_helper.dart';
import '../data/models/note_model.dart';

enum NoteSortOption {
  lastEditedDesc,
  dateCreatedDesc,
  dateCreatedAsc,
  titleAsc,
  titleDesc,
}

extension NoteSortOptionExtension on NoteSortOption {
  String get label {
    switch (this) {
      case NoteSortOption.lastEditedDesc:
        return 'Last Edited (Newest)';
      case NoteSortOption.dateCreatedDesc:
        return 'Date Created (Newest)';
      case NoteSortOption.dateCreatedAsc:
        return 'Date Created (Oldest)';
      case NoteSortOption.titleAsc:
        return 'Title (A → Z)';
      case NoteSortOption.titleDesc:
        return 'Title (Z → A)';
    }
  }

  String get id {
    switch (this) {
      case NoteSortOption.lastEditedDesc:
        return 'lastEditedDesc';
      case NoteSortOption.dateCreatedDesc:
        return 'dateCreatedDesc';
      case NoteSortOption.dateCreatedAsc:
        return 'dateCreatedAsc';
      case NoteSortOption.titleAsc:
        return 'titleAsc';
      case NoteSortOption.titleDesc:
        return 'titleDesc';
    }
  }

  static NoteSortOption fromId(String id) {
    switch (id) {
      case 'dateCreatedDesc':
        return NoteSortOption.dateCreatedDesc;
      case 'dateCreatedAsc':
        return NoteSortOption.dateCreatedAsc;
      case 'titleAsc':
        return NoteSortOption.titleAsc;
      case 'titleDesc':
        return NoteSortOption.titleDesc;
      case 'lastEditedDesc':
      default:
        return NoteSortOption.lastEditedDesc;
    }
  }
}

class NotesProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<NoteModel> _allNotes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedColorFilter;
  int? _selectedFolderFilter;
  NoteSortOption _sortOption = NoteSortOption.lastEditedDesc;

  NotesProvider() {
    _loadSavedSortOption();
  }

  Future<void> _loadSavedSortOption() async {
    final prefs = await PreferencesService.getInstance();
    _sortOption = NoteSortOptionExtension.fromId(prefs.sortOption);
    notifyListeners();
  }

  List<NoteModel> get allNotes => _filteredNotes();
  List<NoteModel> get pinnedNotes => _filteredNotes().where((n) => n.isPinned).toList();
  List<NoteModel> get unpinnedNotes => _filteredNotes().where((n) => !n.isPinned).toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedColorFilter => _selectedColorFilter;
  int? get selectedFolderFilter => _selectedFolderFilter;
  int get totalNotesCount => _allNotes.length;
  NoteSortOption get sortOption => _sortOption;

  List<NoteModel> _filteredNotes() {
    final filtered = _allNotes.where((note) {
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

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortOption) {
        case NoteSortOption.lastEditedDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case NoteSortOption.dateCreatedDesc:
          return b.createdAt.compareTo(a.createdAt);
        case NoteSortOption.dateCreatedAsc:
          return a.createdAt.compareTo(b.createdAt);
        case NoteSortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case NoteSortOption.titleDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> setSortOption(NoteSortOption option) async {
    _sortOption = option;
    notifyListeners();
    final prefs = await PreferencesService.getInstance();
    await prefs.setSortOption(option.id);
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

  Future<int?> duplicateNote(int id) async {
    try {
      final original = _allNotes.firstWhere((n) => n.id == id);
      final now = DateTime.now().toIso8601String();
      final baseTitle = original.title.isEmpty ? 'Untitled Note' : original.title;
      final duplicate = NoteModel(
        title: '$baseTitle (Copy)',
        content: original.content,
        folderId: original.folderId,
        colorHex: original.colorHex,
        isPinned: false,
        createdAt: now,
        updatedAt: now,
      );
      final newId = await _db.insertNote(duplicate);
      await loadNotes();
      AudioService().playRustle();
      return newId;
    } catch (_) {
      return null;
    }
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
