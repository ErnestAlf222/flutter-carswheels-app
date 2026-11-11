import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('muestra el texto de estado vacío', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyStateWidget())),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.emptyStateTitle), findsOneWidget);
  });
}
