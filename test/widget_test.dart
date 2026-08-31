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

  testWidgets('EmptyStateView renders animation canvas', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateView(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(EmptyStateView), findsOneWidget);
  });
}
