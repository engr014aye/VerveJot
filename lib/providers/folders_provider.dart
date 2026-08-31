import 'package:flutter/foundation.dart';
import '../data/database/database_helper.dart';
import '../data/models/folder_model.dart';
import '../core/services/audio_service.dart';

class FoldersProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<FolderModel> _folders = [];
  bool _isLoading = false;
  int? _selectedFolderId;

  List<FolderModel> get folders => _folders;
  bool get isLoading => _isLoading;
  int? get selectedFolderId => _selectedFolderId;

  FolderModel? get selectedFolder {
    if (_selectedFolderId == null) return null;
    try {
      return _folders.firstWhere((f) => f.id == _selectedFolderId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _folders = await _db.getFolders();
    } catch (_) {
      _folders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFolder(int? folderId) {
    if (_selectedFolderId != folderId) {
      _selectedFolderId = folderId;
      notifyListeners();
    }
  }

  Future<int> createFolder({
    required String name,
    required String colorHex,
    required String icon,
  }) async {
    final folder = FolderModel(
      name: name.trim().isEmpty ? 'New Folder' : name.trim(),
      colorHex: colorHex,
      icon: icon,
      createdAt: DateTime.now().toIso8601String(),
    );

    final id = await _db.insertFolder(folder);
    await loadFolders();
    AudioService().playTap();
    return id;
  }

  Future<void> updateFolder(FolderModel folder) async {
    await _db.updateFolder(folder);
    await loadFolders();
    AudioService().playTap();
  }

  Future<void> deleteFolder(int id) async {
    await _db.deleteFolder(id);
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
    }
    await loadFolders();
    AudioService().playDelete();
  }
}
