import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../data/models/folder_model.dart';
import '../../providers/folders_provider.dart';

class FolderDialogs {
  FolderDialogs._();

  static const List<Map<String, dynamic>> availableIcons = [
    {'name': 'folder_rounded', 'icon': Icons.folder_rounded},
    {'name': 'work_rounded', 'icon': Icons.work_rounded},
    {'name': 'person_rounded', 'icon': Icons.person_rounded},
    {'name': 'lightbulb_rounded', 'icon': Icons.lightbulb_rounded},
    {'name': 'book_rounded', 'icon': Icons.menu_book_rounded},
    {'name': 'star_rounded', 'icon': Icons.star_rounded},
    {'name': 'fitness_center_rounded', 'icon': Icons.fitness_center_rounded},
    {'name': 'shopping_bag_rounded', 'icon': Icons.shopping_bag_rounded},
    {'name': 'music_note_rounded', 'icon': Icons.music_note_rounded},
    {'name': 'code_rounded', 'icon': Icons.code_rounded},
    {'name': 'home_rounded', 'icon': Icons.home_rounded},
    {'name': 'favorite_rounded', 'icon': Icons.favorite_rounded},
  ];

  static IconData getIconData(String iconName) {
    final found = availableIcons.firstWhere(
      (item) => item['name'] == iconName,
      orElse: () => {'icon': Icons.folder_rounded},
    );
    return found['icon'] as IconData;
  }

  static Future<int?> showCreateFolderDialog(BuildContext context) async {
    final nameController = TextEditingController();
    String selectedColor = AppColors.toHex(AppColors.primary);
    String selectedIcon = 'folder_rounded';

    return await showDialog<int?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;

          return AlertDialog(
            title: const Text(
              'Create Folder',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
            ),
            content: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Folder name (e.g. Work, Ideas)',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Color Accent',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppColors.noteColors.map((color) {
                      final hex = AppColors.toHex(color);
                      final isSelected = selectedColor == hex;

                      return BouncingButton(
                        shrinkScale: 0.85,
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => selectedColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Folder Icon',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableIcons.map((item) {
                      final iconName = item['name'] as String;
                      final iconData = item['icon'] as IconData;
                      final isSelected = selectedIcon == iconName;
                      final color = AppColors.fromHex(selectedColor);

                      return BouncingButton(
                        shrinkScale: 0.85,
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => selectedIcon = iconName),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.2)
                                : (isDark ? AppColors.oledSurface : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Icon(
                            iconData,
                            size: 20,
                            color: isSelected ? color : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, null),
                child: const Text('Cancel'),
              ),
              BouncingButton(
                onTap: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final foldersProvider = dialogCtx.read<FoldersProvider>();
                  final id = await foldersProvider.createFolder(
                    name: name,
                    colorHex: selectedColor,
                    icon: selectedIcon,
                  );
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx, id);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> showEditFolderDialog(BuildContext context, FolderModel folder) async {
    final nameController = TextEditingController(text: folder.name);
    String selectedColor = folder.colorHex;
    String selectedIcon = folder.icon;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;

          return AlertDialog(
            title: const Text(
              'Edit Folder',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
            ),
            content: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Folder name',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Color Accent',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppColors.noteColors.map((color) {
                      final hex = AppColors.toHex(color);
                      final isSelected = selectedColor == hex;

                      return BouncingButton(
                        shrinkScale: 0.85,
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => selectedColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Folder Icon',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableIcons.map((item) {
                      final iconName = item['name'] as String;
                      final iconData = item['icon'] as IconData;
                      final isSelected = selectedIcon == iconName;
                      final color = AppColors.fromHex(selectedColor);

                      return BouncingButton(
                        shrinkScale: 0.85,
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => selectedIcon = iconName),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.2)
                                : (isDark ? AppColors.oledSurface : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Icon(
                            iconData,
                            size: 20,
                            color: isSelected ? color : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              BouncingButton(
                onTap: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final foldersProvider = dialogCtx.read<FoldersProvider>();
                  await foldersProvider.updateFolder(
                    folder.copyWith(
                      name: name,
                      colorHex: selectedColor,
                      icon: selectedIcon,
                    ),
                  );
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
