import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('muestra el título y las tarjetas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PlaceholderPage(title: AppTexts.homePageTitle)),
    );
    expect(find.text(AppTexts.homePageTitle), findsOneWidget);
    expect(find.text(AppTexts.placeholderItemLabel), findsWidgets);
  });
}
