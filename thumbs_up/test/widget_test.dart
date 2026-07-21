import 'package:flutter_test/flutter_test.dart';

import 'package:thumbs_up/main.dart';

void main() {
  testWidgets('App boots to the Launch screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ThumbsUpApp());

    expect(
      find.textContaining('Thumbs', findRichText: true),
      findsOneWidget,
    );
  });
}
