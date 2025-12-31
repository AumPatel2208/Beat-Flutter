// Basic Flutter widget test for Beat app.

import 'package:flutter_test/flutter_test.dart';

import 'package:beat_app/app/app.dart';

void main() {
  testWidgets('BeatApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BeatApp());

    // Verify app title is displayed
    await tester.pumpAndSettle();
    
    // Basic smoke test - app should render without crashing
    expect(find.text('Beat'), findsWidgets);
  });
}
