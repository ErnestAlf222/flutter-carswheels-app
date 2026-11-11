import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _childKey = Key('child');

Widget _buildApp({required bool disableAnimations}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Scaffold(
        body: AnimatedEntryWidget(index: 2, child: SizedBox(key: _childKey)),
      ),
    ),
  );
}

void main() {
  testWidgets('con animaciones normales el hijo aparece tras pumpAndSettle', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(disableAnimations: false));
    await tester.pumpAndSettle();
    expect(find.byKey(_childKey), findsOneWidget);
  });

  testWidgets('con disableAnimations el hijo aparece de inmediato', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(disableAnimations: true));
    expect(find.byKey(_childKey), findsOneWidget);
  });
}
