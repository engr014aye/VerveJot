import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vervejot/core/widgets/bouncing_button.dart';
import 'package:vervejot/core/widgets/empty_state_view.dart';

void main() {
  testWidgets('BouncingButton renders and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BouncingButton(
              onTap: () => tapped = true,
              enableAudio: false,
              enableHaptic: false,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap Me'), findsOneWidget);

    await tester.tap(find.text('Tap Me'));
    await tester.pumpAndSettle();

    expect(tapped, true);
  });

  testWidgets('EmptyStateView renders title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            icon: Icons.note_alt_rounded,
            title: 'No Notes',
            subtitle: 'Start creating notes now.',
          ),
        ),
      ),
    );

    expect(find.text('No Notes'), findsOneWidget);
    expect(find.text('Start creating notes now.'), findsOneWidget);
  });
}
