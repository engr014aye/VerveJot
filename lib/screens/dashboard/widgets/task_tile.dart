import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spring_curves.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/tasks_provider.dart';

class TaskTile extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    this.onEdit,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
      value: widget.task.isDone ? 1.0 : 0.0,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: SpringCurve.bouncy,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.isDone != widget.task.isDone) {
      if (widget.task.isDone) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tasksProvider = context.read<TasksProvider>();

    return Dismissible(
      key: ValueKey('task_${widget.task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
      ),
      onDismissed: (_) {
        if (widget.task.id != null) {
          tasksProvider.deleteTask(widget.task.id!);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.oledCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Custom Spring Checkbox
            BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (widget.task.id != null) {
                  tasksProvider.toggleTask(widget.task.id!, !widget.task.isDone);
                }
              },
              child: AnimatedContainer(
                duration: AppDurations.quick,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.task.isDone
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.task.isDone
                        ? AppColors.primary
                        : (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted),
                    width: 2,
                  ),
                ),
                child: widget.task.isDone
                    ? ScaleTransition(
                        scale: _scaleAnimation,
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.black,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            // Title & Due Date
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: AppDurations.quick,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                        color: widget.task.isDone
                            ? (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted)
                            : (isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary),
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: widget.task.isDone
                            ? (isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted)
                            : null,
                      ),
                      child: Text(
                        widget.task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.task.dueDate != null && widget.task.dueDate!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.task.dueDate!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Delete Button
            BouncingButton(
              shrinkScale: 0.85,
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (widget.task.id != null) {
                  tasksProvider.deleteTask(widget.task.id!);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
