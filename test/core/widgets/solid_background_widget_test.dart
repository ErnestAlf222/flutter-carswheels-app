import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void _expectOpaque(WidgetTester tester, Finder solid) {
  expect(solid, findsOneWidget);
  final box = tester.widget<ColoredBox>(
    find.descendant(of: solid, matching: find.byType(ColoredBox)).first,
  );
  expect(box.color, AppColors.background);
  expect(box.color.a, 1.0);
}

void main() {
  testWidgets('pinta un fondo opaco del color de la página', (tester) async {
    await tester.pumpWidget(
      _host(const SolidBackgroundWidget(child: Text('a'))),
    );
    _expectOpaque(tester, find.byType(SolidBackgroundWidget));
  });

  testWidgets('estado vacío, error y mensaje en línea tienen fondo opaco', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const EmptyStateWidget()));
    _expectOpaque(
      tester,
      find.ancestor(
        of: find.text(AppTexts.emptyStateTitle),
        matching: find.byType(SolidBackgroundWidget),
      ),
    );
    await tester.pumpWidget(_host(ErrorStateWidget(onRetry: () {})));
    _expectOpaque(
      tester,
      find.ancestor(
        of: find.text(AppTexts.errorStateTitle),
        matching: find.byType(SolidBackgroundWidget),
      ),
    );
    await tester.pumpWidget(
      _host(
        InlineMessageWidget(message: 'msg', actionLabel: 'ok', onAction: () {}),
      ),
    );
    _expectOpaque(
      tester,
      find.ancestor(
        of: find.text('msg'),
        matching: find.byType(SolidBackgroundWidget),
      ),
    );
  });
}
