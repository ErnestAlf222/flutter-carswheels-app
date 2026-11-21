import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/detail_test_support.dart';

const _entries = [
  SpecEntryEntity(label: 'Combustible', value: 'Gasolina regular'),
  SpecEntryEntity(label: 'Transmisión', value: 'Automática'),
];

Widget _bubble(List<SpecEntryEntity> entries) => MaterialApp(
  home: Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: DetailSpecBubbleWidget(entries: entries, subtitle: 'Versión'),
        ),
      ],
    ),
  ),
);

void main() {
  setUpAll(disableFontFetching);

  group('burbuja de ficha técnica', () {
    testWidgets('sin datos no aparece', (tester) async {
      await tester.pumpWidget(_bubble(const []));
      expect(find.byIcon(Symbols.list_alt), findsNothing);
    });

    testWidgets('con datos muestra la burbuja de tinta con ícono amarillo', (
      tester,
    ) async {
      await tester.pumpWidget(_bubble(_entries));
      final icon = tester.widget<Icon>(find.byIcon(Symbols.list_alt));
      expect(icon.color, AppColors.accent);
      expect(find.text('Gasolina regular'), findsNothing);
    });

    testWidgets('se abre con el toque y se cierra con la X', (tester) async {
      await tester.pumpWidget(_bubble(_entries));
      await tester.tap(find.byIcon(Symbols.list_alt));
      await tester.pumpAndSettle();
      expect(find.text('Gasolina regular'), findsOneWidget);
      expect(find.text(AppTexts.specSheetTitle), findsOneWidget);
      await tester.tap(find.byIcon(Symbols.close));
      await tester.pumpAndSettle();
      expect(find.text('Gasolina regular'), findsNothing);
    });

    testWidgets('se cierra con un toque fuera del panel', (tester) async {
      await tester.pumpWidget(_bubble(_entries));
      await tester.tap(find.byIcon(Symbols.list_alt));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Gasolina regular'), findsNothing);
    });

    testWidgets('se cierra arrastrando hacia abajo', (tester) async {
      await tester.pumpWidget(_bubble(_entries));
      await tester.tap(find.byIcon(Symbols.list_alt));
      await tester.pumpAndSettle();
      await tester.drag(
        find.text(AppTexts.specSheetTitle),
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gasolina regular'), findsNothing);
    });

    testWidgets('si la versión nueva no tiene datos, desaparece', (
      tester,
    ) async {
      await tester.pumpWidget(_bubble(_entries));
      await tester.pumpWidget(_bubble(const []));
      expect(find.byIcon(Symbols.list_alt), findsNothing);
    });
  });

  group('crédito de la foto', () {
    Widget credit(GalleryState state) => detailHost(
      const DetailPhotoCreditWidget(),
      galleryCubit: buildMockGalleryCubit(state),
    );

    testWidgets('muestra autor y licencia', (tester) async {
      await tester.pumpWidget(
        credit(GalleryState(photos: [testPhoto(author: 'Ana')])),
      );
      expect(
        find.text(AppTexts.photoCreditLabel('Ana', 'CC BY 4.0')),
        findsOneWidget,
      );
    });

    testWidgets('sin autor no se muestra la línea', (tester) async {
      await tester.pumpWidget(
        credit(GalleryState(photos: [testPhoto(author: '  ')])),
      );
      expect(find.textContaining('Foto:'), findsNothing);
    });

    testWidgets('al tocarla entrega la fuente', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(
        detailHost(
          DetailPhotoCreditWidget(onOpenSource: opened.add),
          galleryCubit: buildMockGalleryCubit(
            GalleryState(photos: [testPhoto(source: 'https://f.test/x')]),
          ),
        ),
      );
      await tester.tap(find.textContaining('Foto:'));
      expect(opened, ['https://f.test/x']);
    });
  });
}
