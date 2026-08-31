import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/note_card.dart';

class PinnedNotesTab extends StatelessWidget {
  const PinnedNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final pinnedNotes = notesProvider.pinnedNotes;

    return RefreshIndicator(
      onRefresh: () => notesProvider.loadNotes(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (pinnedNotes.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.push_pin_outlined,
                title: AppStrings.emptyPinnedTitle,
                subtitle: AppStrings.emptyPinnedSubtitle,
              ),
            )
          else if (settingsProvider.isGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => NoteCard(note: pinnedNotes[index]),
                  childCount: pinnedNotes.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: NoteCard(note: pinnedNotes[index]),
                  ),
                  childCount: pinnedNotes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
