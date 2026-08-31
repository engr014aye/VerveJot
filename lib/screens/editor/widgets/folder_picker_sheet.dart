import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../core/widgets/modal_sheet_wrapper.dart';
import '../../../providers/folders_provider.dart';
import '../../folders/folder_dialogs.dart';

class FolderPickerSheet extends StatelessWidget {
  final int? currentFolderId;
  final ValueChanged<int?> onFolderSelected;

  const FolderPickerSheet({
    super.key,
    required this.currentFolderId,
    required this.onFolderSelected,
  });

  static Future<int?> show({
    required BuildContext context,
    required int? currentFolderId,
  }) {
    return ModalSheetWrapper.show<int?>(
      context: context,
      builder: (ctx) => FolderPickerSheet(
        currentFolderId: currentFolderId,
        onFolderSelected: (id) => Navigator.of(ctx).pop(id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foldersProvider = context.watch<FoldersProvider>();

    return ModalSheetWrapper(
      title: 'Assign Folder',
      subtitle: 'Organize this note into a designated workspace folder',
      trailing: BouncingButton(
        shrinkScale: 0.88,
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final newFolderId = await FolderDialogs.showCreateFolderDialog(context);
          if (newFolderId != null) {
            onFolderSelected(newFolderId);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'New',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Option 1: None / Unassigned
          BouncingButton(
            shrinkScale: 0.97,
            borderRadius: BorderRadius.circular(14),
            onTap: () => onFolderSelected(null),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: currentFolderId == null
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (isDark ? AppColors.oledCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: currentFolderId == null
                      ? AppColors.primary
                      : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                  width: currentFolderId == null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 20,
                    color: currentFolderId == null ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No Folder (Root)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: currentFolderId == null ? FontWeight.w700 : FontWeight.w500,
                        color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (currentFolderId == null)
                    const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),

          // Folder List
          ...foldersProvider.folders.map((folder) {
            final isSelected = currentFolderId == folder.id;
            final folderColor = AppColors.fromHex(folder.colorHex);

            return BouncingButton(
              key: ValueKey('picker_folder_${folder.id}'),
              shrinkScale: 0.97,
              borderRadius: BorderRadius.circular(14),
              onTap: () => onFolderSelected(folder.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? folderColor.withValues(alpha: 0.15)
                      : (isDark ? AppColors.oledCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? folderColor
                        : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      FolderDialogs.getIconData(folder.icon),
                      size: 20,
                      color: folderColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        folder.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_rounded, size: 18, color: folderColor),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
