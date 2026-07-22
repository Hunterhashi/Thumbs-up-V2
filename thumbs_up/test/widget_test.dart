import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thumbs_up/main.dart';

void main() {
  testWidgets('App boots to the Launch screen', (WidgetTester tester) async {
    // The Home screen reads personal-best/onboarding state from
    // shared_preferences on init; mock it so those reads don't hit a real
    // (missing) platform channel in the test environment.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ThumbsUpApp());

    expect(find.textContaining('Thumbs', findRichText: true), findsOneWidget);

    // Flush the Launch screen's pending timers (spinner fade-in + the
    // delayed navigation to Home) so the test doesn't leak them.
    await tester.pump(const Duration(seconds: 3));
  });
}
