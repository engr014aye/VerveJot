import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';
import '../../providers/notes_provider.dart';
import 'widgets/color_tag_picker.dart';
import 'widgets/folder_picker_dialog.dart';

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
  bool _isSavingDb = false;
  bool _needsSaveAgain = false;
  bool _isPreviewMode = false;
  Timer? _debounceTimer;

  int _wordCount = 0;
  int _charCount = 0;

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

    _titleFocus.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _calculateStats();
  }

  void _calculateStats() {
    final text = _contentController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    final chars = _contentController.text.length;
    setState(() {
      _wordCount = words;
      _charCount = chars;
    });
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
      _calculateStats();
    }
  }

  void _onTextChanged() {
    _calculateStats();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    _debounceTimer?.cancel();

    if (_isSavingDb) {
      _needsSaveAgain = true;
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _noteId == null) {
      return;
    }

    _isSavingDb = true;
    if (mounted) setState(() => _isSaving = true);
    final now = DateTime.now().toIso8601String();

    try {
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
          });
        }
      }
    } catch (_) {
      // Failsafe
    } finally {
      _isSavingDb = false;
      if (mounted) setState(() => _isSaving = false);

      if (_needsSaveAgain) {
        _needsSaveAgain = false;
        _saveNote();
      }
    }
  }

  Future<void> _onSaveButtonClicked() async {
    _titleFocus.unfocus();
    _contentFocus.unfocus();

    // Show folder selection dialog
    if (mounted) {
      final selectedFolderId = await FolderPickerDialog.show(
        context: context,
        currentFolderId: _folderId,
      );
      if (mounted) {
        setState(() {
          _folderId = selectedFolderId;
        });
      }
    }

    await _saveNote();

    if (mounted) {
      AudioService().playChime();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handleBackPress() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If note is completely empty, leave without prompt
    if (title.isEmpty && content.isEmpty) {
      return true;
    }

    // Show iOS-style confirmation dialog
    final shouldLeave = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Save Note?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Text('Would you like to save your note before leaving?'),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop(false);
              // Open folder picker then save
              final selectedFolderId = await FolderPickerDialog.show(
                context: context,
                currentFolderId: _folderId,
              );
              if (mounted) {
                setState(() {
                  _folderId = selectedFolderId;
                });
                await _saveNote();
                AudioService().playChime();
                if (mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  void _toggleChecklistItem(int lineIndex, bool currentChecked) {
    final lines = _contentController.text.split('\n');
    if (lineIndex >= 0 && lineIndex < lines.length) {
      final line = lines[lineIndex];
      if (currentChecked && line.startsWith('- [x] ')) {
        lines[lineIndex] = '- [ ] ${line.substring(6)}';
        AudioService().playTap();
      } else if (!currentChecked && line.startsWith('- [ ] ')) {
        lines[lineIndex] = '- [x] ${line.substring(6)}';
        AudioService().playChime();
      }
      _contentController.text = lines.join('\n');
      _saveNote();
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
    if (_isSaving) return 'Saving...';
    if (_updatedAt.isEmpty) return 'Draft';
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

    final accentColor = AppColors.fromHex(_colorHex, defaultColor: AppColors.primary);
    final isAccentDark = ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark;
    final tickColor = isAccentDark ? Colors.white : Colors.black;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackPress();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
        appBar: AppBar(
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final shouldPop = await _handleBackPress();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.oledCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isSaving ? AppColors.warning : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _formatSavedTime(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Preview / Edit Mode Switch
            BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => _isPreviewMode = !_isPreviewMode);
                AudioService().playTap();
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _isPreviewMode
                      ? accentColor.withValues(alpha: 0.18)
                      : (isDark ? AppColors.oledCard : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPreviewMode
                        ? accentColor
                        : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                  ),
                ),
                child: Icon(
                  _isPreviewMode ? Icons.edit_note_rounded : Icons.visibility_outlined,
                  size: 18,
                  color: _isPreviewMode
                      ? accentColor
                      : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),

            // Pin Toggle Button
            BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => _isPinned = !_isPinned);
                _saveNote();
                AudioService().playTap();
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _isPinned
                      ? AppColors.warning.withValues(alpha: 0.18)
                      : (isDark ? AppColors.oledCard : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPinned
                        ? AppColors.warning
                        : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                  ),
                ),
                child: Icon(
                  _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: 18,
                  color: _isPinned
                      ? AppColors.warning
                      : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),

            // Color Picker Swatch
            BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final selected = await ColorTagPicker.show(
                  context: context,
                  currentColorHex: _colorHex,
                );
                setState(() => _colorHex = selected);
                _saveNote();
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.oledCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Highlighted Save Tick Icon Button
            BouncingButton(
              shrinkScale: 0.88,
              borderRadius: BorderRadius.circular(12),
              onTap: _onSaveButtonClicked,
              child: Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.only(left: 3, right: 12),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: tickColor,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Word and Character Stats Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.oledCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
                      ),
                    ),
                    child: Text(
                      '$_wordCount words • $_charCount chars',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Main Editor Canvas / Preview Area (Click anywhere to write)
            Expanded(
              child: _isPreviewMode
                  ? _buildMarkdownPreview(isDark)
                  : _buildEditorFields(isDark, accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorFields(bool isDark, Color accentColor) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!_contentFocus.hasFocus) {
          _contentFocus.requestFocus();
        }
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // Title Input Field
          TextField(
            controller: _titleController,
            focusNode: _titleFocus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _contentFocus.requestFocus(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Note Title...',
              hintStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? AppColors.oledTextMuted.withValues(alpha: 0.6) : AppColors.lightTextMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 16),

          // Body Content Field (Tapping anywhere in canvas opens focus)
          TextField(
            controller: _contentController,
            focusNode: _contentFocus,
            maxLines: null,
            minLines: 12,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: accentColor,
            style: TextStyle(
              fontSize: 16,
              height: 1.65,
              letterSpacing: -0.1,
              color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Start writing notes, task checklists (- [ ] task), or ideas...',
              hintStyle: TextStyle(
                fontSize: 16,
                height: 1.65,
                color: isDark ? AppColors.oledTextMuted.withValues(alpha: 0.6) : AppColors.lightTextMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview(bool isDark) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),
        ],
        if (content.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 40,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No content to preview yet.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
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

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineIndex = i;

      if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
        final isChecked = line.startsWith('- [x] ');
        final itemText = line.substring(6);

        rendered.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: BouncingButton(
              shrinkScale: 0.98,
              onTap: () => _toggleChecklistItem(lineIndex, isChecked),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isChecked
                      ? (isDark ? AppColors.oledCard.withValues(alpha: 0.5) : AppColors.lightCard.withValues(alpha: 0.6))
                      : (isDark ? AppColors.oledCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: isChecked ? AppColors.primary : (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        itemText,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                          color: isChecked
                              ? (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted)
                              : (isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (line.trim().isEmpty) {
        rendered.add(const SizedBox(height: 10));
      } else {
        rendered.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                letterSpacing: -0.1,
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
