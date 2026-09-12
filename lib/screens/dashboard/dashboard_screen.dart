import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/in_app_update_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../providers/notes_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tasks_provider.dart';
import '../editor/note_editor_screen.dart';
import '../settings/settings_screen.dart';
import 'tabs/all_notes_tab.dart';
import 'tabs/folders_tab.dart';
import 'tabs/pinned_notes_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _currentTabIndex = 0;
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        AudioService().playTap();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMandatoryAppUpdate();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _isSearchOpen = true;
    });
    AudioService().playTap();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearchOpen = false;
      _searchController.clear();
    });
    context.read<NotesProvider>().setSearchQuery('');
    context.read<TasksProvider>().setSearchQuery('');
    AudioService().playTap();
  }

  Future<void> _checkMandatoryAppUpdate() async {
    final result = await InAppUpdateService().checkForImmediateUpdate();
    if (result == InAppUpdateResult.updateRequiredDialogNeeded && mounted) {
      _showMandatoryUpdateDialog();
    }
  }

  void _showMandatoryUpdateDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          title: const Text(
            'Update Required',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'A new version of VerveJot is available on Google Play Store with important fixes and improvements. Please update now to continue.',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                const packageName = 'com.zahraini.vervejot';
                final marketUri = Uri.parse('market://details?id=$packageName');
                final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
                try {
                  final launched = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
                  if (!launched) {
                    await launchUrl(webUri, mode: LaunchMode.externalApplication);
                  }
                } catch (_) {
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                'Update Now',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    AudioService().playTap();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesProvider = context.read<NotesProvider>();
    final currentSort = notesProvider.sortOption;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.oledSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sort Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              ...NoteSortOption.values.map((option) {
                final isSelected = option == currentSort;
                return ListTile(
                  leading: Icon(
                    _getSortIcon(option),
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                  ),
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
                      : null,
                  onTap: () {
                    AudioService().playTap();
                    notesProvider.setSortOption(option);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSortIcon(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.lastEditedDesc:
        return Icons.access_time_rounded;
      case NoteSortOption.dateCreatedDesc:
        return Icons.calendar_today_rounded;
      case NoteSortOption.dateCreatedAsc:
        return Icons.history_rounded;
      case NoteSortOption.titleAsc:
        return Icons.sort_by_alpha_rounded;
      case NoteSortOption.titleDesc:
        return Icons.sort_by_alpha_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settingsProvider = context.watch<SettingsProvider>();
    final notesProvider = context.read<NotesProvider>();
    final tasksProvider = context.read<TasksProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
      appBar: AppBar(
        titleSpacing: _isSearchOpen ? 0 : 20,
        leading: _isSearchOpen
            ? BouncingButton(
                shrinkScale: 0.85,
                onTap: _closeSearch,
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              )
            : null,
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.oledTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onChanged: (query) {
                  notesProvider.setSearchQuery(query);
                  tasksProvider.setSearchQuery(query);
                },
              )
            : Row(
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
          // Search Action (or Clear if search is open)
          if (_isSearchOpen)
            if (_searchController.text.isNotEmpty)
              BouncingButton(
                shrinkScale: 0.85,
                onTap: () {
                  _searchController.clear();
                  notesProvider.setSearchQuery('');
                  tasksProvider.setSearchQuery('');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Icon(
                    Icons.clear_rounded,
                    size: 20,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              )
            else
              const SizedBox.shrink()
          else ...[
            // Search Icon
            BouncingButton(
              shrinkScale: 0.85,
              onTap: _openSearch,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),

            // View Mode Switcher (Grid / List for Notes & Pinned)
            if (_currentTabIndex == 0 || _currentTabIndex == 1) ...[
              BouncingButton(
                shrinkScale: 0.85,
                onTap: () => settingsProvider.toggleViewMode(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    settingsProvider.isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    size: 22,
                    color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              BouncingButton(
                shrinkScale: 0.85,
                onTap: () => _showSortOptions(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    Icons.sort_rounded,
                    size: 22,
                    color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],

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
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              labelPadding: EdgeInsets.zero,
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
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
              tabs: const [
                Tab(text: 'All Notes'),
                Tab(text: 'Pinned'),
                Tab(text: 'Folders'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: BouncingButton(
        shrinkScale: 0.88,
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          AudioService().playTap();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 32,
            color: Colors.black,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          AllNotesTab(),
          PinnedNotesTab(),
          FoldersTab(),
        ],
      ),
    );
  }
}
