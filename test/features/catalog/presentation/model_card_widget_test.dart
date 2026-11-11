import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget card(String name, {double width = 300}) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: ModelCardWidget(name: name, index: 0),
        ),
      ),
    ),
  );

  testWidgets('muestra el nombre y expone su etiqueta semántica', (
    tester,
  ) async {
    await tester.pumpWidget(card('Civic 4Dr'));
    await tester.pumpAndSettle();
    expect(find.text('Civic 4Dr'), findsOneWidget);
    expect(find.bySemanticsLabel('Civic 4Dr'), findsOneWidget);
  });

  testWidgets('con nombre largo limita a dos líneas y no desborda', (
    tester,
  ) async {
    await tester.pumpWidget(
      card('Un modelo con un nombre larguísimo ' * 6, width: 220),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('el recuadro del icono tiene el tamaño configurado', (
    tester,
  ) async {
    await tester.pumpWidget(card('Civic'));
    await tester.pumpAndSettle();
    final box = find.ancestor(
      of: find.byType(Icon),
      matching: find.byType(Container),
    );
    expect(
      tester.getSize(box.first),
      const Size.square(UiConfig.modelThumbnailSize),
    );
  });
}
