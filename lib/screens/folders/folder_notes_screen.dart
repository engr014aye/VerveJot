import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../data/models/folder_model.dart';
import '../../providers/folders_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/settings_provider.dart';
import '../dashboard/widgets/note_card.dart';
import '../editor/note_editor_screen.dart';
import 'folder_dialogs.dart';

class FolderNotesScreen extends StatelessWidget {
  final FolderModel folder;

  const FolderNotesScreen({
    super.key,
    required this.folder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesProvider = context.watch<NotesProvider>();
    final foldersProvider = context.watch<FoldersProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final currentFolder = foldersProvider.folders.firstWhere(
      (f) => f.id == folder.id,
      orElse: () => folder,
    );

    final folderNotes = notesProvider.getNotesForFolder(folder.id ?? -1);
    final folderColor = AppColors.fromHex(currentFolder.colorHex);

    return Scaffold(
      backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: BouncingButton(
          shrinkScale: 0.85,
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        actions: [
          // Edit Folder Button
          BouncingButton(
            shrinkScale: 0.85,
            onTap: () => FolderDialogs.showEditFolderDialog(context, currentFolder),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.edit_outlined, size: 20),
            ),
          ),

          // Delete Folder Button
          BouncingButton(
            shrinkScale: 0.85,
            onTap: () => _confirmDeleteFolder(context, currentFolder),
            child: const Padding(
              padding: EdgeInsets.only(left: 4.0, right: 14.0),
              child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
            ),
          ),
        ],
      ),
      floatingActionButton: BouncingButton(
        shrinkScale: 0.9,
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(initialFolderId: currentFolder.id),
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: folderColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: folderColor.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Folder Header Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: folderColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: folderColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      FolderDialogs.getIconData(currentFolder.icon),
                      size: 28,
                      color: folderColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentFolder.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${folderNotes.length} ${folderNotes.length == 1 ? "note" : "notes"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notes List / Grid
          if (folderNotes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.note_alt_outlined,
                title: 'Empty Folder',
                subtitle: 'No notes in ${currentFolder.name} yet. Tap + to add one.',
                actionLabel: 'Create Note in Folder',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoteEditorScreen(initialFolderId: currentFolder.id),
                    ),
                  );
                },
              ),
            )
          else if (settingsProvider.isGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => NoteCard(note: folderNotes[index]),
                  childCount: folderNotes.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: NoteCard(note: folderNotes[index], isCompact: false),
                  ),
                  childCount: folderNotes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context, FolderModel folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Notes inside "${folder.name}" will not be deleted; they will be moved to the unassigned root section.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          BouncingButton(
            onTap: () async {
              Navigator.pop(ctx);
              if (folder.id != null) {
                final foldersProvider = context.read<FoldersProvider>();
                await foldersProvider.deleteFolder(folder.id!);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
