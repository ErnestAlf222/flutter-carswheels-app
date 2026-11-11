import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('muestra los textos y el botón llama al callback', (
    tester,
  ) async {
    int retryCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ErrorStateWidget(onRetry: () => retryCalls++)),
      ),
    );
    expect(find.text(AppTexts.errorStateTitle), findsOneWidget);
    expect(find.text(AppTexts.retryButtonLabel), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    expect(retryCalls, 1);
  });
}
