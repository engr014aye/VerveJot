import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../editor/note_editor_screen.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';

class AllNotesTab extends StatelessWidget {
  const AllNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final notes = notesProvider.allNotes;

    return RefreshIndicator(
      onRefresh: () => notesProvider.loadNotes(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Search & Filters Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: SearchBarWidget(),
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
                    : AppStrings.emptyNotesTitle,
                subtitle: notesProvider.searchQuery.isNotEmpty
                    ? 'Try searching for something else or clearing your filters.'
                    : AppStrings.emptyNotesSubtitle,
                actionLabel: notesProvider.searchQuery.isEmpty ? 'Create First Note' : null,
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NoteEditorScreen(),
                    ),
                  );
                },
              ),
            )
          else if (settingsProvider.isGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
