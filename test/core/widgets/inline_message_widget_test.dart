import 'package:animate_do/animate_do.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(VoidCallback onAction, {bool disableAnimations = false}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Scaffold(
            body: InlineMessageWidget(
              message: AppTexts.refreshFailedLabel,
              actionLabel: AppTexts.retryButtonLabel,
              onAction: onAction,
            ),
          ),
        ),
      );

  testWidgets('muestra el mensaje y llama al callback con el botón', (
    tester,
  ) async {
    final calls = <int>[];
    await tester.pumpWidget(host(() => calls.add(1)));
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.refreshFailedLabel), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    expect(calls, hasLength(1));
  });

  testWidgets('el botón usa el color link y el área tocable mínima', (
    tester,
  ) async {
    await tester.pumpWidget(host(() {}));
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(find.text(AppTexts.retryButtonLabel));
    expect(text.style?.color, AppColors.link);
    final size = tester.getSize(find.byType(TextButton));
    expect(
      size.height,
      greaterThanOrEqualTo(CarouselConfig.arrowTouchTargetSize),
    );
  });

  testWidgets('entra con FadeIn salvo con disableAnimations', (tester) async {
    await tester.pumpWidget(host(() {}));
    expect(find.byType(FadeIn), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(() {}, disableAnimations: true));
    expect(find.byType(FadeIn), findsNothing);
  });
}
