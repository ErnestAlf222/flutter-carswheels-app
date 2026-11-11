import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('llama a onPressed y usa el degradado', (tester) async {
    int calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            label: AppTexts.retryButtonLabel,
            onPressed: () => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    expect(calls, 1);
    final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.gradient, AppGradients.primary);
  });
}
