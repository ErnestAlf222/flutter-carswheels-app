import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    required bool isRefreshing,
    bool disableAnimations = false,
    VoidCallback? onTap,
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: RefreshableContentWidget(
          isRefreshing: isRefreshing,
          child: TextButton(onPressed: onTap, child: const Text('toca')),
        ),
      ),
    ),
  );

  double opacity(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  testWidgets('sin refrescar muestra el hijo opaco y recibe toques', (
    tester,
  ) async {
    final taps = <int>[];
    await tester.pumpWidget(
      host(isRefreshing: false, onTap: () => taps.add(1)),
    );
    expect(opacity(tester), 1.0);
    await tester.tap(find.text('toca'));
    expect(taps, hasLength(1));
  });

  testWidgets('refrescando atenúa e ignora los toques', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(host(isRefreshing: true, onTap: () => taps.add(1)));
    await tester.pumpAndSettle();
    expect(opacity(tester), UiConfig.dimmedOpacity);
    await tester.tap(find.text('toca'), warnIfMissed: false);
    expect(taps, isEmpty);
  });

  testWidgets('la atenuación se anima en el tiempo configurado', (
    tester,
  ) async {
    await tester.pumpWidget(host(isRefreshing: false));
    await tester.pumpWidget(host(isRefreshing: true));
    await tester.pump(
      const Duration(
        milliseconds: AnimationConfig.dimDurationMilliseconds ~/ 2,
      ),
    );
    final midway = tester
        .renderObject<RenderAnimatedOpacity>(find.byType(AnimatedOpacity))
        .opacity
        .value;
    expect(midway, lessThan(1.0));
    expect(midway, greaterThan(UiConfig.dimmedOpacity));
    await tester.pumpAndSettle();
  });

  testWidgets('con disableAnimations atenúa sin animación', (tester) async {
    await tester.pumpWidget(host(isRefreshing: false, disableAnimations: true));
    await tester.pumpWidget(host(isRefreshing: true, disableAnimations: true));
    await tester.pump();
    final animated = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(animated.duration, Duration.zero);
    expect(
      tester
          .renderObject<RenderAnimatedOpacity>(find.byType(AnimatedOpacity))
          .opacity
          .value,
      UiConfig.dimmedOpacity,
    );
  });
}
