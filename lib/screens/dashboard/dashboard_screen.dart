import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../providers/notes_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tasks_provider.dart';
import '../settings/settings_screen.dart';
import 'tabs/all_notes_tab.dart';
import 'tabs/daily_tasks_tab.dart';
import 'tabs/folders_tab.dart';
import 'tabs/pinned_notes_tab.dart';
import 'widgets/speed_dial_fab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        AudioService().playTap();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showQuickTaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Quick Daily Task',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'What needs to be done today?',
          ),
          onSubmitted: (_) {
            final title = controller.text.trim();
            if (title.isNotEmpty) {
              context.read<TasksProvider>().createTask(title: title);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          BouncingButton(
            onTap: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                context.read<TasksProvider>().createTask(title: title);
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
                'Add Task',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
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
    final settingsProvider = context.watch<SettingsProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final tasksProvider = context.watch<TasksProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // View Mode Switcher
          if (_currentTabIndex == 0 || _currentTabIndex == 1)
            BouncingButton(
              shrinkScale: 0.85,
              onTap: () => settingsProvider.toggleViewMode(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  settingsProvider.isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  size: 22,
                  color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),

          // Settings Action
          BouncingButton(
            shrinkScale: 0.85,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 18.0),
              child: Icon(
                Icons.settings_outlined,
                size: 22,
                color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.oledCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.black,
              unselectedLabelColor: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.tabAllNotes),
                      if (notesProvider.totalNotesCount > 0) ...[
                        const SizedBox(width: 4),
                        Text('(${notesProvider.totalNotesCount})', style: const TextStyle(fontSize: 10)),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.tabPinned),
                      if (notesProvider.pinnedNotes.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text('(${notesProvider.pinnedNotes.length})', style: const TextStyle(fontSize: 10)),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.tabTasks),
                      if (tasksProvider.pendingCount > 0) ...[
                        const SizedBox(width: 4),
                        Text('(${tasksProvider.pendingCount})', style: const TextStyle(fontSize: 10)),
                      ],
                    ],
                  ),
                ),
                const Tab(text: AppStrings.tabFolders),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDialFab(
        onQuickTask: _showQuickTaskDialog,
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          AllNotesTab(),
          PinnedNotesTab(),
          DailyTasksTab(),
          FoldersTab(),
        ],
      ),
    );
  }
}
