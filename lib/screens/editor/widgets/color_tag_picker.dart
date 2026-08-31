import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../core/widgets/modal_sheet_wrapper.dart';

class ColorTagPicker extends StatelessWidget {
  final String? selectedColorHex;
  final ValueChanged<String?> onColorSelected;

  const ColorTagPicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  static Future<String?> show({
    required BuildContext context,
    required String? currentColorHex,
  }) {
    return ModalSheetWrapper.show<String?>(
      context: context,
      builder: (ctx) => ColorTagPicker(
        selectedColorHex: currentColorHex,
        onColorSelected: (hex) => Navigator.of(ctx).pop(hex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetWrapper(
      title: 'Note Color Accent',
      subtitle: 'Highlight your note with a distinctive visual tone',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              // Clear color option
              BouncingButton(
                shrinkScale: 0.85,
                borderRadius: BorderRadius.circular(24),
                onTap: () => onColorSelected(null),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColorHex == null ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
                      width: selectedColorHex == null ? 2.5 : 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.format_color_reset_rounded,
                    size: 22,
                    color: selectedColorHex == null ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),

              // Swatches
              ...AppColors.noteColors.map((color) {
                final hex = AppColors.toHex(color);
                final isSelected = selectedColorHex == hex;

                return BouncingButton(
                  shrinkScale: 0.85,
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onColorSelected(hex),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
