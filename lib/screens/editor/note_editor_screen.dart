import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';
import '../../providers/folders_provider.dart';
import '../../providers/notes_provider.dart';
import 'widgets/color_tag_picker.dart';
import 'widgets/folder_picker_sheet.dart';
import 'widgets/markdown_toolbar.dart';

class NoteEditorScreen extends StatefulWidget {
  final int? noteId;
  final int? initialFolderId;

  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.initialFolderId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  int? _noteId;
  int? _folderId;
  bool _isPinned = false;
  String? _colorHex;
  String _createdAt = '';
  String _updatedAt = '';
  bool _isSaving = false;
  bool _isPreviewMode = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId;
    _folderId = widget.initialFolderId;

    if (_noteId != null) {
      _loadExistingNote();
    } else {
      _createdAt = DateTime.now().toIso8601String();
      _updatedAt = _createdAt;
    }

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  Future<void> _loadExistingNote() async {
    final note = await DatabaseHelper.instance.getNoteById(_noteId!);
    if (note != null && mounted) {
      setState(() {
        _titleController.text = note.title;
        _contentController.text = note.content;
        _folderId = note.folderId;
        _isPinned = note.isPinned;
        _colorHex = note.colorHex;
        _createdAt = note.createdAt;
        _updatedAt = note.updatedAt;
      });
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If both empty and new note, don't persist empty record
    if (title.isEmpty && content.isEmpty && _noteId == null) {
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now().toIso8601String();

    final notesProvider = context.read<NotesProvider>();

    if (_noteId == null) {
      final newNote = NoteModel(
        folderId: _folderId,
        title: _titleController.text,
        content: _contentController.text,
        isPinned: _isPinned,
        colorHex: _colorHex,
        createdAt: now,
        updatedAt: now,
      );
      final id = await notesProvider.createNote(newNote);
      if (mounted) {
        setState(() {
          _noteId = id;
          _createdAt = now;
          _updatedAt = now;
          _isSaving = false;
        });
      }
    } else {
      final updatedNote = NoteModel(
        id: _noteId,
        folderId: _folderId,
        title: _titleController.text,
        content: _contentController.text,
        isPinned: _isPinned,
        colorHex: _colorHex,
        createdAt: _createdAt,
        updatedAt: now,
      );
      await notesProvider.updateNote(updatedNote);
      if (mounted) {
        setState(() {
          _updatedAt = now;
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  String _formatSavedTime() {
    if (_updatedAt.isEmpty) return 'New';
    try {
      final dt = DateTime.parse(_updatedAt);
      return 'Saved ${DateFormat.jm().format(dt)}';
    } catch (_) {
      return 'Saved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foldersProvider = context.watch<FoldersProvider>();

    final assignedFolder = _folderId != null
        ? foldersProvider.folders.cast().firstWhere(
            (f) => f.id == _folderId,
            orElse: () => null,
          )
        : null;

    final accentColor = AppColors.fromHex(_colorHex, defaultColor: AppColors.primary);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _saveNote();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
        appBar: AppBar(
          leading: BouncingButton(
            shrinkScale: 0.85,
            onTap: () async {
              await _saveNote();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          title: Text(
            _isSaving ? 'Saving...' : _formatSavedTime(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
            ),
          ),
          actions: [
            // Preview Toggle
            BouncingButton(
              shrinkScale: 0.85,
              onTap: () {
                setState(() => _isPreviewMode = !_isPreviewMode);
                AudioService().playTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  _isPreviewMode ? Icons.edit_rounded : Icons.visibility_rounded,
                  size: 22,
                  color: _isPreviewMode ? AppColors.primary : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),

            // Pin Toggle
            BouncingButton(
              shrinkScale: 0.85,
              onTap: () {
                setState(() => _isPinned = !_isPinned);
                _saveNote();
                AudioService().playTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: 22,
                  color: _isPinned ? AppColors.primary : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),

            // Color Picker
            BouncingButton(
              shrinkScale: 0.85,
              onTap: () async {
                final selected = await ColorTagPicker.show(
                  context: context,
                  currentColorHex: _colorHex,
                );
                setState(() => _colorHex = selected);
                _saveNote();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                  ),
                ),
              ),
            ),

            // Folder Assignment
            BouncingButton(
              shrinkScale: 0.85,
              onTap: () async {
                final selected = await FolderPickerSheet.show(
                  context: context,
                  currentFolderId: _folderId,
                );
                setState(() => _folderId = selected);
                _saveNote();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  assignedFolder != null ? Icons.folder_rounded : Icons.create_new_folder_outlined,
                  size: 22,
                  color: assignedFolder != null
                      ? AppColors.fromHex(assignedFolder.colorHex)
                      : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),

            // Delete Action
            if (_noteId != null)
              BouncingButton(
                shrinkScale: 0.85,
                onTap: () async {
                  final notesProvider = context.read<NotesProvider>();
                  await notesProvider.deleteNote(_noteId!);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 4.0, right: 14.0),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Folder & Category Tag Bar
            if (assignedFolder != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.fromHex(assignedFolder.colorHex).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.fromHex(assignedFolder.colorHex).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_rounded,
                      size: 14,
                      color: AppColors.fromHex(assignedFolder.colorHex),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      assignedFolder.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.fromHex(assignedFolder.colorHex),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Editor / Preview Body
            Expanded(
              child: _isPreviewMode
                  ? _buildMarkdownPreview(isDark)
                  : _buildEditorFields(isDark),
            ),

            // Formatting Toolbar
            if (!_isPreviewMode)
              MarkdownToolbar(
                controller: _contentController,
                focusNode: _contentFocus,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorFields(bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Title Input
        TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Note Title',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),

        const SizedBox(height: 12),

        // Content Input
        TextField(
          controller: _contentController,
          focusNode: _contentFocus,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Write markdown notes, action checklists, thoughts...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownPreview(bool isDark) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
        ],
        if (content.isEmpty)
          Center(
            child: Text(
              'No content to preview.',
              style: TextStyle(
                color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          _renderFormattedMarkdown(content, isDark),
      ],
    );
  }

  Widget _renderFormattedMarkdown(String text, bool isDark) {
    final lines = text.split('\n');
    final List<Widget> rendered = [];

    for (final line in lines) {
      if (line.startsWith('## ')) {
        rendered.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Text(
              line.substring(3),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('# ')) {
        rendered.add(
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text(
              line.substring(2),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
        final isChecked = line.startsWith('- [x] ');
        final itemText = line.substring(6);
        rendered.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 18,
                  color: isChecked ? AppColors.primary : (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemText,
                    style: TextStyle(
                      fontSize: 15,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked
                          ? (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted)
                          : (isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        rendered.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, right: 8.0),
                  child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('> ')) {
        rendered.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.oledCard : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 3),
              ),
            ),
            child: Text(
              line.substring(2),
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        );
      } else if (line.trim() == '---') {
        rendered.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
        );
      } else if (line.trim().isEmpty) {
        rendered.add(const SizedBox(height: 8));
      } else {
        rendered.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rendered,
    );
  }
}
