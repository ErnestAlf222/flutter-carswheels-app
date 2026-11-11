import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  int olderTaps = 0;
  int newerTaps = 0;

  setUp(() {
    olderTaps = 0;
    newerTaps = 0;
  });

  Widget selector({bool canShowOlder = true, bool canShowNewer = true}) =>
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: YearSelectorWidget(
              year: 2024,
              canShowOlder: canShowOlder,
              canShowNewer: canShowNewer,
              onOlder: () => olderTaps++,
              onNewer: () => newerTaps++,
            ),
          ),
        ),
      );

  testWidgets('muestra el año y tiene el alto configurado', (tester) async {
    await tester.pumpWidget(selector());
    expect(find.text('2024'), findsOneWidget);
    expect(
      tester.getSize(find.byType(YearSelectorWidget)).height,
      CarouselConfig.yearSelectorHeight,
    );
  });

  testWidgets('las flechas llaman a sus callbacks', (tester) async {
    await tester.pumpWidget(selector());
    await tester.tap(find.bySemanticsLabel(AppTexts.olderYearLabel));
    await tester.tap(find.bySemanticsLabel(AppTexts.newerYearLabel));
    expect(olderTaps, 1);
    expect(newerTaps, 1);
  });

  testWidgets('las flechas deshabilitadas no responden y se atenúan', (
    tester,
  ) async {
    await tester.pumpWidget(selector(canShowOlder: false, canShowNewer: false));
    await tester.tap(find.bySemanticsLabel(AppTexts.olderYearLabel));
    await tester.tap(find.bySemanticsLabel(AppTexts.newerYearLabel));
    expect(olderTaps, 0);
    expect(newerTaps, 0);
    final icons = tester.widgetList<Icon>(find.byType(Icon));
    for (final icon in icons) {
      expect(
        icon.color,
        AppColors.subtle.withValues(alpha: CarouselConfig.disabledArrowOpacity),
      );
    }
  });

  testWidgets('solo se deshabilita la flecha del extremo', (tester) async {
    await tester.pumpWidget(selector(canShowOlder: false));
    await tester.tap(find.bySemanticsLabel(AppTexts.olderYearLabel));
    await tester.tap(find.bySemanticsLabel(AppTexts.newerYearLabel));
    expect(olderTaps, 0);
    expect(newerTaps, 1);
  });
}
