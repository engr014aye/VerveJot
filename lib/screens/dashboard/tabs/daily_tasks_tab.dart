import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/tasks_provider.dart';
import '../widgets/task_tile.dart';

class DailyTasksTab extends StatefulWidget {
  const DailyTasksTab({super.key});

  @override
  State<DailyTasksTab> createState() => _DailyTasksTabState();
}

class _DailyTasksTabState extends State<DailyTasksTab> {
  final TextEditingController _taskInputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void dispose() {
    _taskInputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _submitQuickTask() {
    final title = _taskInputController.text.trim();
    if (title.isEmpty) return;

    final tasksProvider = context.read<TasksProvider>();
    tasksProvider.createTask(title: title);
    _taskInputController.clear();
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task) {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Task description',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          BouncingButton(
            onTap: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final tasksProvider = context.read<TasksProvider>();
                tasksProvider.updateTask(task.copyWith(title: newTitle));
              }
              Navigator.pop(ctx);
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
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tasksProvider = context.watch<TasksProvider>();
    final tasks = tasksProvider.tasks;

    final progress = tasksProvider.completionPercentage;
    final total = tasksProvider.totalCount;
    final completed = tasksProvider.completedCount;

    return RefreshIndicator(
      onRefresh: () => tasksProvider.loadTasks(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Quick Task Input Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                    Expanded(
                      child: TextField(
                        controller: _taskInputController,
                        focusNode: _inputFocus,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _submitQuickTask(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Add a new action item...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    BouncingButton(
                      shrinkScale: 0.85,
                      borderRadius: BorderRadius.circular(12),
                      onTap: _submitQuickTask,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Progress Card
          if (total > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.oledCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '$completed of $total done (${(progress * 100).toInt()}%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark ? AppColors.oledSurface : AppColors.lightBackground,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Filter Segmented Buttons & Clear Completed Action
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  // Filter Chips
                  _buildFilterButton('All (${tasksProvider.totalCount})', TaskFilterMode.all, tasksProvider, isDark),
                  const SizedBox(width: 8),
                  _buildFilterButton('Pending (${tasksProvider.pendingCount})', TaskFilterMode.pending, tasksProvider, isDark),
                  const SizedBox(width: 8),
                  _buildFilterButton('Done (${tasksProvider.completedCount})', TaskFilterMode.completed, tasksProvider, isDark),
                  const Spacer(),
                  if (completed > 0)
                    BouncingButton(
                      shrinkScale: 0.85,
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => tasksProvider.clearCompleted(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.cleaning_services_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tasks List
          if (tasks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.checklist_rtl_rounded,
                title: AppStrings.emptyTasksTitle,
                subtitle: AppStrings.emptyTasksSubtitle,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TaskTile(
                    task: tasks[index],
                    onEdit: () => _showEditTaskDialog(context, tasks[index]),
                  ),
                  childCount: tasks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    TaskFilterMode mode,
    TasksProvider provider,
    bool isDark,
  ) {
    final isSelected = provider.filterMode == mode;

    return BouncingButton(
      shrinkScale: 0.9,
      borderRadius: BorderRadius.circular(10),
      onTap: () => provider.setFilterMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : (isDark ? AppColors.oledCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
