import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../providers/folders_provider.dart';
import '../../../providers/notes_provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesProvider = context.watch<NotesProvider>();
    final foldersProvider = context.watch<FoldersProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.oledCard : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (val) => notesProvider.setSearchQuery(val),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                BouncingButton(
                  shrinkScale: 0.85,
                  onTap: () {
                    _controller.clear();
                    notesProvider.setSearchQuery('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.clear_rounded,
                      size: 18,
                      color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Color & Folder Filter Chips
        if (foldersProvider.folders.isNotEmpty || notesProvider.selectedColorFilter != null || notesProvider.selectedFolderFilter != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Reset Filters Chip
                if (notesProvider.selectedColorFilter != null || notesProvider.selectedFolderFilter != null) ...[
                  BouncingButton(
                    shrinkScale: 0.9,
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => notesProvider.clearFilters(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: 13, color: AppColors.error),
                          SizedBox(width: 4),
                          Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Folder Filter Chips
                ...foldersProvider.folders.map((folder) {
                  final isSelected = notesProvider.selectedFolderFilter == folder.id;
                  final folderColor = AppColors.fromHex(folder.colorHex);

                  return BouncingButton(
                    key: ValueKey('filter_folder_${folder.id}'),
                    shrinkScale: 0.9,
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => notesProvider.setFolderFilter(folder.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? folderColor.withValues(alpha: 0.2)
                            : (isDark ? AppColors.oledCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? folderColor
                              : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: folderColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            folder.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Color Filter Palette Chips
                ...AppColors.noteColors.take(5).map((color) {
                  final hex = AppColors.toHex(color);
                  final isSelected = notesProvider.selectedColorFilter == hex;

                  return BouncingButton(
                    key: ValueKey('filter_color_$hex'),
                    shrinkScale: 0.85,
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => notesProvider.setColorFilter(hex),
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
