import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../providers/folders_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/tasks_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final TextEditingController _importController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _exportBackup() async {
    setState(() => _isProcessing = true);
    try {
      await BackupService.instance.shareBackup();
      AudioService().playChime();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importBackup({required bool replaceExisting}) async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a valid JSON backup text first.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final backup = await BackupService.instance.validateAndParse(raw);
      await BackupService.instance.restoreFromBackup(backup, replaceExisting: replaceExisting);

      if (mounted) {
        final foldersProv = context.read<FoldersProvider>();
        final notesProv = context.read<NotesProvider>();
        final tasksProv = context.read<TasksProvider>();

        await foldersProv.loadFolders();
        await notesProv.loadNotes();
        await tasksProv.loadTasks();

        AudioService().playChime();
        _importController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully restored ${backup.notes.length} notes, ${backup.tasks.length} tasks, and ${backup.folders.length} folders!',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesProvider = context.watch<NotesProvider>();
    final foldersProvider = context.watch<FoldersProvider>();
    final tasksProvider = context.watch<TasksProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: BouncingButton(
          shrinkScale: 0.85,
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // Current Database Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.oledCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Local Database Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Notes', '${notesProvider.totalNotesCount}', AppColors.primary, isDark),
                    _buildStatCol('Tasks', '${tasksProvider.totalCount}', AppColors.secondary, isDark),
                    _buildStatCol('Folders', '${foldersProvider.folders.length}', AppColors.warning, isDark),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Export Section
          const Text(
            'Export Backup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate a complete, unencrypted JSON backup file containing all your notes, folders, and task items.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 14),
          BouncingButton(
            shrinkScale: 0.96,
            borderRadius: BorderRadius.circular(16),
            onTap: _isProcessing ? null : _exportBackup,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_upload_outlined, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isProcessing ? 'Processing...' : 'Export & Share Backup',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Import Section
          const Text(
            'Import Backup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          Text(
            'Paste your JSON backup payload below to restore your notes and tasks.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _importController,
            maxLines: 5,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '{\n  "app": "VerveJot",\n  "version": 1,\n  ...\n}',
              filled: true,
              fillColor: isDark ? AppColors.oledCard : AppColors.lightCard,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BouncingButton(
                  shrinkScale: 0.95,
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isProcessing ? null : () => _importBackup(replaceExisting: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.oledCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Merge with Existing',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BouncingButton(
                  shrinkScale: 0.95,
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isProcessing ? null : () => _showConfirmReplaceDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text(
                        'Replace All Data',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmReplaceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace All Existing Data?'),
        content: const Text(
          'This will permanently overwrite all existing notes, tasks, and folders with the imported backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          BouncingButton(
            onTap: () {
              Navigator.pop(ctx);
              _importBackup(replaceExisting: true);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Overwrite & Restore',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
