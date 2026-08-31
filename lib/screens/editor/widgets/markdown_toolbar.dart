import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bouncing_button.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  void _insertFormatting({
    required String prefix,
    String suffix = '',
    String defaultText = '',
    bool atLineStart = false,
  }) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) {
      final newText = '$text$prefix$defaultText$suffix';
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length - suffix.length,
        ),
      );
      focusNode.requestFocus();
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final beforeText = text.substring(0, selection.start);
    final afterText = text.substring(selection.end);

    if (atLineStart) {
      // Find beginning of current line
      final lastNewline = beforeText.lastIndexOf('\n');
      final lineStart = lastNewline == -1 ? 0 : lastNewline + 1;
      final preLine = text.substring(0, lineStart);
      final currentLine = text.substring(lineStart, selection.end);

      final replacement = '$prefix$currentLine';
      final newText = '$preLine$replacement$afterText';

      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: lineStart + replacement.length,
        ),
      );
    } else {
      final content = selectedText.isEmpty ? defaultText : selectedText;
      final newText = '$beforeText$prefix$content$suffix$afterText';
      final newSelectionStart = selection.start + prefix.length;
      final newSelectionEnd = newSelectionStart + content.length;

      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: newSelectionStart,
          extentOffset: newSelectionEnd,
        ),
      );
    }

    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      _ToolbarItem(
        icon: Icons.format_bold_rounded,
        tooltip: 'Bold',
        onTap: () => _insertFormatting(prefix: '**', suffix: '**', defaultText: 'bold text'),
      ),
      _ToolbarItem(
        icon: Icons.format_italic_rounded,
        tooltip: 'Italic',
        onTap: () => _insertFormatting(prefix: '*', suffix: '*', defaultText: 'italic text'),
      ),
      _ToolbarItem(
        icon: Icons.title_rounded,
        tooltip: 'Heading',
        onTap: () => _insertFormatting(prefix: '## ', atLineStart: true),
      ),
      _ToolbarItem(
        icon: Icons.checklist_rounded,
        tooltip: 'Checklist',
        onTap: () => _insertFormatting(prefix: '- [ ] ', atLineStart: true),
      ),
      _ToolbarItem(
        icon: Icons.format_list_bulleted_rounded,
        tooltip: 'Bullet List',
        onTap: () => _insertFormatting(prefix: '- ', atLineStart: true),
      ),
      _ToolbarItem(
        icon: Icons.format_quote_rounded,
        tooltip: 'Quote',
        onTap: () => _insertFormatting(prefix: '> ', atLineStart: true),
      ),
      _ToolbarItem(
        icon: Icons.code_rounded,
        tooltip: 'Code',
        onTap: () => _insertFormatting(prefix: '`', suffix: '`', defaultText: 'code'),
      ),
      _ToolbarItem(
        icon: Icons.strikethrough_s_rounded,
        tooltip: 'Strikethrough',
        onTap: () => _insertFormatting(prefix: '~~', suffix: '~~', defaultText: 'text'),
      ),
      _ToolbarItem(
        icon: Icons.horizontal_rule_rounded,
        tooltip: 'Divider',
        onTap: () => _insertFormatting(prefix: '\n---\n', defaultText: ''),
      ),
    ];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.oledCard : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
            child: BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(10),
              onTap: item.onTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ToolbarItem {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarItem({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}
