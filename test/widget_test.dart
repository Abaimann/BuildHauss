// BuildHaus widget tests placeholder.
// Full widget tests require mock database and providers.
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/main.dart';
import 'package:buildhaus/app/app.dart';

void main() {
  testWidgets('BuildHaus app smoke test', (WidgetTester tester) async {
    // Basic smoke test - verify app can be built
    await tester.pumpWidget(const BuildHausApp());
    await tester.pump();

    // Verify no crash on startup
    expect(find.byType(BuildHausApp), findsOneWidget);
  });
}
