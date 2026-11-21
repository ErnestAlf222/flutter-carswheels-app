import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _key = Key('hijo');

Widget _app({required bool reduced, int index = 2, int tick = 0}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduced),
  child: MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          Text('$tick'),
          StaggeredEntryWidget(
            index: index,
            child: const SizedBox(key: _key, width: 10, height: 10),
          ),
        ],
      ),
    ),
  ),
);

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.ancestor(of: find.byKey(_key), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  testWidgets('con animaciones aparece con fundido y se asienta', (
    tester,
  ) async {
    await tester.pumpWidget(_app(reduced: false));
    expect(_opacity(tester), lessThan(1.0));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1.0);
  });

  testWidgets('con disableAnimations no anima', (tester) async {
    await tester.pumpWidget(_app(reduced: true));
    expect(_opacity(tester), 1.0);
  });

  testWidgets('un rebuild no vuelve a animar', (tester) async {
    await tester.pumpWidget(_app(reduced: false));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(reduced: false, tick: 1));
    expect(_opacity(tester), 1.0);
  });

  testWidgets('pasado el tope de elementos no se retrasa', (tester) async {
    await tester.pumpWidget(
      _app(reduced: false, index: AnimationConfig.staggerMaxAnimatedItems),
    );
    expect(_opacity(tester), 1.0);
  });
}
