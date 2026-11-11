import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const items = [
    FloatingNavItemModel(icon: Symbols.home, label: AppTexts.navHomeLabel),
    FloatingNavItemModel(icon: Symbols.search, label: AppTexts.navSearchLabel),
  ];

  Widget build({required bool visible, required ValueChanged<int> onSelected}) {
    return MaterialApp(
      home: Scaffold(
        body: FloatingNavBar(
          items: items,
          currentIndex: 0,
          onSelected: onSelected,
          visible: visible,
        ),
      ),
    );
  }

  testWidgets('muestra los botones y avisa el índice tocado', (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(build(visible: true, onSelected: taps.add));
    expect(find.byIcon(Symbols.home), findsOneWidget);
    expect(find.byIcon(Symbols.search), findsOneWidget);
    await tester.tap(find.byIcon(Symbols.search));
    expect(taps, [1]);
  });

  testWidgets('el botón activo usa el degradado principal', (tester) async {
    await tester.pumpWidget(build(visible: true, onSelected: (_) {}));
    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration as BoxDecoration);
    expect(
      decorations.where((d) => d.gradient == AppGradients.primary),
      hasLength(1),
    );
  });

  testWidgets('oculto no recibe toques', (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(build(visible: false, onSelected: taps.add));
    await tester.tap(find.byIcon(Symbols.home), warnIfMissed: false);
    expect(taps, isEmpty);
  });
}
