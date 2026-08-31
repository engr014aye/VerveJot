import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/folders_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../editor/note_editor_screen.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isCompact;

  const NoteCard({
    super.key,
    required this.note,
    this.isCompact = false,
  });

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat.jm().format(dt);
      }
      return DateFormat.MMMd().format(dt);
    } catch (_) {
      return '';
    }
  }

  String _cleanContentPreview(String raw) {
    return raw
        .replaceAll(RegExp(r'#+\s*'), '')
        .replaceAll(RegExp(r'[*_~`>]'), '')
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
        .replaceAll(RegExp(r'- \[[ x]\]\s*'), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foldersProvider = context.watch<FoldersProvider>();

    final folder = note.folderId != null
        ? foldersProvider.folders.cast().firstWhere(
            (f) => f.id == note.folderId,
            orElse: () => null,
          )
        : null;

    final accentColor = AppColors.fromHex(note.colorHex, defaultColor: AppColors.primary);
    final contentPreview = _cleanContentPreview(note.content);

    return BouncingButton(
      shrinkScale: 0.96,
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NoteEditorScreen(noteId: note.id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      onLongPress: () => _showNoteActions(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.oledCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: note.isPinned
                ? accentColor.withValues(alpha: 0.5)
                : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
            width: note.isPinned ? 1.5 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Accent Bar & Pin Badge
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                if (folder != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.fromHex(folder.colorHex).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      folder.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.fromHex(folder.colorHex),
                      ),
                    ),
                  ),
                const Spacer(),
                if (note.isPinned)
                  Icon(
                    Icons.push_pin_rounded,
                    size: 15,
                    color: accentColor,
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Note Title
            Text(
              note.title.isEmpty ? 'Untitled Note' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
              ),
            ),

            if (contentPreview.isNotEmpty && !isCompact) ...[
              const SizedBox(height: 6),
              Text(
                contentPreview,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Footer (Date)
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesProvider = context.read<NotesProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.oledSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                  color: AppColors.primary,
                ),
                title: Text(note.isPinned ? 'Unpin Note' : 'Pin Note to Top'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (note.id != null) {
                    notesProvider.togglePin(note.id!);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: const Text('Delete Note', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  if (note.id != null) {
                    notesProvider.deleteNote(note.id!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
