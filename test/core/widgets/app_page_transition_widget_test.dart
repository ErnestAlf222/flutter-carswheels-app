import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('con disableAnimations cambia de inmediato', (tester) async {
    Widget build(String text) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AppPageTransition(child: Text(text, key: ValueKey(text))),
      ),
    );
    await tester.pumpWidget(build(AppTexts.homePageTitle));
    await tester.pumpWidget(build(AppTexts.searchPageTitle));
    await tester.pump();
    expect(find.text(AppTexts.homePageTitle), findsNothing);
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
  });
}
