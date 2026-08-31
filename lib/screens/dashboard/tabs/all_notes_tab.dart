import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/note_card.dart';

class AllNotesTab extends StatelessWidget {
  const AllNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final notes = notesProvider.allNotes;

    final hasActiveFilters = notesProvider.selectedColorFilter != null ||
        notesProvider.selectedFolderFilter != null;

    return RefreshIndicator(
      onRefresh: () => notesProvider.loadNotes(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Filter Chips Header (if folders or color filters exist)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: FilterChipsBar(),
            ),
          ),

          // Content
          if (notes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.note_add_rounded,
                title: notesProvider.searchQuery.isNotEmpty
                    ? 'No Notes Matching Query'
                    : (hasActiveFilters ? 'No Filtered Notes' : AppStrings.emptyNotesTitle),
                subtitle: notesProvider.searchQuery.isNotEmpty
                    ? 'Try searching for something else or clearing your search.'
                    : (hasActiveFilters
                        ? 'Try clearing your folder or color filters to see all notes.'
                        : AppStrings.emptyNotesSubtitle),
              ),
            )
          else if (settingsProvider.isGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => NoteCard(note: notes[index]),
                  childCount: notes.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: NoteCard(note: notes[index]),
                  ),
                  childCount: notes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
