import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/widgets/bouncing_button.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color accentColor;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.accentColor = AppColors.primary,
  });

  void _toggleInlineFormatting(String marker) {
    AudioService().playTap();
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid || selection.start == -1) {
      final newText = '$text$marker$marker';
      final cursorOffset = text.length + marker.length;
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorOffset),
      );
      focusNode.requestFocus();
      return;
    }

    final start = selection.start;
    final end = selection.end;

    // Case 1: Text is highlighted / selected
    if (start != end) {
      final selectedText = text.substring(start, end);
      final before = text.substring(0, start);
      final after = text.substring(end);

      // Check if selection is already wrapped with marker
      if (selectedText.startsWith(marker) &&
          selectedText.endsWith(marker) &&
          selectedText.length >= marker.length * 2) {
        final unwrapped = selectedText.substring(
          marker.length,
          selectedText.length - marker.length,
        );
        final newText = '$before$unwrapped$after';
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start,
            extentOffset: start + unwrapped.length,
          ),
        );
      }
      // Check if surrounding text outside selection is wrapped with marker
      else if (before.endsWith(marker) && after.startsWith(marker)) {
        final newBefore = before.substring(0, before.length - marker.length);
        final newAfter = after.substring(marker.length);
        final newText = '$newBefore$selectedText$newAfter';
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start - marker.length,
            extentOffset: end - marker.length,
          ),
        );
      } else {
        // Wrap selection
        final newText = '$before$marker$selectedText$marker$after';
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start + marker.length,
            extentOffset: end + marker.length,
          ),
        );
      }
    }
    // Case 2: Cursor is at a single position
    else {
      final cursor = start;
      final before = text.substring(0, cursor);
      final after = text.substring(cursor);

      // Insert empty marker pair and place cursor between them
      final newText = '$before$marker$marker$after';
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor + marker.length),
      );
    }

    focusNode.requestFocus();
  }

  void _toggleLinePrefix(String targetPrefix) {
    AudioService().playTap();
    final text = controller.text;
    final selection = controller.selection;

    final cursorPosition = selection.isValid && selection.start != -1
        ? selection.start
        : text.length;

    final beforeCursor = text.substring(0, cursorPosition);
    final afterCursor = text.substring(cursorPosition);

    final lastNewline = beforeCursor.lastIndexOf('\n');
    final lineStart = lastNewline == -1 ? 0 : lastNewline + 1;

    final nextNewline = afterCursor.indexOf('\n');
    final lineEnd = nextNewline == -1 ? text.length : cursorPosition + nextNewline;

    final preLine = text.substring(0, lineStart);
    final currentLine = text.substring(lineStart, lineEnd);
    final postLine = text.substring(lineEnd);

    // Identify existing list prefixes
    final prefixRegex = RegExp(r'^(\- \[[ x]\] |\d+\. |\- |\> |\#\#? )');
    final match = prefixRegex.firstMatch(currentLine);

    String updatedLine;
    int delta = 0;

    if (match != null) {
      final existingPrefix = match.group(0)!;
      final lineContent = currentLine.substring(existingPrefix.length);

      if (existingPrefix.trim() == targetPrefix.trim()) {
        // Toggle OFF
        updatedLine = lineContent;
        delta = -existingPrefix.length;
      } else {
        // Replace with target prefix
        updatedLine = '$targetPrefix$lineContent';
        delta = targetPrefix.length - existingPrefix.length;
      }
    } else {
      // Add target prefix
      updatedLine = '$targetPrefix$currentLine';
      delta = targetPrefix.length;
    }

    final newText = '$preLine$updatedLine$postLine';
    final newCursor = (cursorPosition + delta).clamp(0, newText.length);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );

    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<_FormatToolItem> items = [
      _FormatToolItem(
        icon: Icons.checklist_rounded,
        label: 'Task',
        onTap: () => _toggleLinePrefix('- [ ] '),
      ),
      _FormatToolItem(
        icon: Icons.format_bold_rounded,
        label: 'Bold',
        onTap: () => _toggleInlineFormatting('**'),
      ),
      _FormatToolItem(
        icon: Icons.format_italic_rounded,
        label: 'Italic',
        onTap: () => _toggleInlineFormatting('*'),
      ),
      _FormatToolItem(
        icon: Icons.format_list_numbered_rounded,
        label: '1. List',
        onTap: () => _toggleLinePrefix('1. '),
      ),
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.oledSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: BouncingButton(
                shrinkScale: 0.90,
                borderRadius: BorderRadius.circular(12),
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? accentColor.withValues(alpha: 0.16)
                        : accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FormatToolItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FormatToolItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
