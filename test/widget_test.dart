import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/shared/widgets/buildhaus_logo.dart';

void main() {
  testWidgets('BuildHaus logo shows identity and tagline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BuildHausLogo())),
      ),
    );
    expect(find.text('BuildHaus'), findsOneWidget);
    expect(find.text('Built for every ride'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Compact logo has no textual tagline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BuildHausLogoCompact())),
      ),
    );
    expect(find.byType(BuildHausLogoCompact), findsOneWidget);
    expect(find.text('Built for every ride'), findsNothing);
  });
}
