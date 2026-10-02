import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BedLinkApp());
    expect(find.text('BedLink'), findsOneWidget);
  });
}
