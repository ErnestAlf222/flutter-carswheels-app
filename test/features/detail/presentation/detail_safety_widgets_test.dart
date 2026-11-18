import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/detail_test_support.dart';

RecallEntity _recall(
  String number, {
  DateTime? date,
  String? component,
  String? summary,
  String? consequence,
  String? remedy,
}) => RecallEntity(
  campaignNumber: number,
  reportDate: date,
  component: component,
  summary: summary,
  consequence: consequence,
  remedy: remedy,
);

void main() {
  setUpAll(disableFontFetching);

  group('estrellas en las cifras', () {
    Widget stats(SafetyLoad<GroupSafetyEntity> safety) =>
        detailHost(DetailStatsCardWidget(detail: testDetail(), safety: safety));

    // Estrellas llenas: las que tienen relleno en el ícono.
    int filledStars(WidgetTester tester) => tester
        .widgetList<Icon>(find.byIcon(Symbols.star))
        .where((icon) => icon.fill == 1)
        .length;

    testWidgets('una sola calificación muestra 5 llenas y el número', (
      tester,
    ) async {
      await tester.pumpWidget(
        stats(
          const SafetyData(
            GroupSafetyEntity(ratedCount: 2, minOverall: 5, maxOverall: 5),
          ),
        ),
      );
      expect(
        find.byIcon(Symbols.star),
        findsNWidgets(UiConfig.safetyStarCount),
      );
      expect(filledStars(tester), 5);
      expect(find.text('5'), findsOneWidget);
      // Sin rango no hay nota de versiones.
      expect(find.textContaining('versiones'), findsNothing);
    });

    testWidgets('un rango muestra 4–5, las estrellas del máximo y la nota', (
      tester,
    ) async {
      await tester.pumpWidget(
        stats(
          const SafetyData(
            GroupSafetyEntity(ratedCount: 3, minOverall: 4, maxOverall: 5),
          ),
        ),
      );
      expect(find.text('4–5'), findsOneWidget);
      expect(filledStars(tester), 5);
      expect(find.text('3 versiones'), findsOneWidget);
    });

    testWidgets('con menos estrellas deja las demás vacías', (tester) async {
      await tester.pumpWidget(
        stats(
          const SafetyData(
            GroupSafetyEntity(ratedCount: 1, minOverall: 3, maxOverall: 3),
          ),
        ),
      );
      expect(filledStars(tester), 3);
      expect(find.byIcon(Symbols.star), findsNWidgets(5));
    });

    testWidgets('la etiqueta de accesibilidad nombra el rango', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        stats(
          const SafetyData(
            GroupSafetyEntity(ratedCount: 3, minOverall: 4, maxOverall: 5),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Calificación de seguridad NHTSA: 4 a 5 de 5 estrellas'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets(
      'sin dato, sin calificar o con error muestra guion sin estrellas',
      (tester) async {
        for (final safety in <SafetyLoad<GroupSafetyEntity>>[
          const SafetyEmpty(),
          const SafetyData(GroupSafetyEntity(ratedCount: 0)),
          const SafetyFailed(NetworkFailure('sin red')),
        ]) {
          await tester.pumpWidget(stats(safety));
          expect(find.byIcon(Symbols.star), findsNothing);
          expect(find.text(AppTexts.noDataLabel), findsOneWidget);
        }
      },
    );

    testWidgets('cargando muestra un esqueleto solo en su celda', (
      tester,
    ) async {
      await tester.pumpWidget(stats(const SafetyLoading()));
      expect(find.byType(SkeletonBarWidget), findsOneWidget);
      expect(find.byIcon(Symbols.star), findsNothing);
      // El resto de las cifras sigue visible.
      expect(find.text('14.6'), findsOneWidget);
      expect(find.text(r'$1,750'), findsOneWidget);
    });
  });

  group('fila de recalls', () {
    Widget rows(
      SafetyLoad<RecallSummaryEntity> recalls, {
      VoidCallback? onTap,
    }) =>
        detailHost(DetailInfoRowsWidget(recalls: recalls, onRecallsTap: onTap));

    testWidgets('muestra el conteo en singular y plural', (tester) async {
      await tester.pumpWidget(
        rows(SafetyData(RecallSummaryEntity(recalls: [_recall('A')]))),
      );
      expect(find.text('1 aviso'), findsOneWidget);
      await tester.pumpWidget(
        rows(
          SafetyData(
            RecallSummaryEntity(
              recalls: [for (int i = 0; i < 11; i++) _recall('R$i')],
            ),
          ),
        ),
      );
      expect(find.text('11 avisos'), findsOneWidget);
    });

    testWidgets('cero confirmado dice Sin avisos y no es tocable', (
      tester,
    ) async {
      final taps = <int>[];
      await tester.pumpWidget(
        rows(
          const SafetyData(RecallSummaryEntity(recalls: [])),
          onTap: () => taps.add(1),
        ),
      );
      expect(find.text(AppTexts.noRecallsLabel), findsOneWidget);
      await tester.tap(find.text(AppTexts.detailRecallsLabel));
      expect(taps, isEmpty);
    });

    testWidgets('nulo o error muestra guion y nunca 0', (tester) async {
      for (final recalls in <SafetyLoad<RecallSummaryEntity>>[
        const SafetyEmpty(),
        const SafetyFailed(NetworkFailure('sin red')),
      ]) {
        await tester.pumpWidget(rows(recalls));
        expect(find.text(AppTexts.noRecallsLabel), findsNothing);
        expect(find.text('0 avisos'), findsNothing);
        // Tres filas de datos vacías más la de recalls.
        expect(find.text(AppTexts.noDataLabel), findsNWidgets(4));
      }
    });

    testWidgets('cargando muestra un esqueleto solo en la fila', (
      tester,
    ) async {
      await tester.pumpWidget(rows(const SafetyLoading()));
      expect(find.byType(SkeletonBarWidget), findsOneWidget);
      expect(find.text(AppTexts.detailRecallsLabel), findsOneWidget);
    });

    testWidgets('con al menos uno, tocar la fila llama a onRecallsTap', (
      tester,
    ) async {
      final taps = <int>[];
      await tester.pumpWidget(
        rows(
          SafetyData(RecallSummaryEntity(recalls: [_recall('A')])),
          onTap: () => taps.add(1),
        ),
      );
      await tester.tap(find.text(AppTexts.detailRecallsLabel));
      expect(taps, hasLength(1));
    });
  });

  group('hoja de recalls', () {
    Widget sheet(List<RecallEntity> recalls) => detailHost(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showRecallsSheet(
            context,
            summary: RecallSummaryEntity(recalls: recalls),
          ),
          child: const Text('abrir'),
        ),
      ),
    );

    Future<void> open(WidgetTester tester, List<RecallEntity> recalls) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 2400);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(sheet(recalls));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('ordena de más reciente a más antigua, sin fecha al final', (
      tester,
    ) async {
      await open(tester, [
        _recall('B', date: DateTime(2020, 5, 1), component: 'Frenos'),
        _recall('C', component: 'Sin fecha aquí'),
        _recall('A', date: DateTime(2023, 3, 5), component: 'Airbag'),
        _recall('D', date: DateTime(2021, 12, 31), component: 'Motor'),
      ]);
      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(top('Airbag'), lessThan(top('Motor')));
      expect(top('Motor'), lessThan(top('Frenos')));
      expect(top('Frenos'), lessThan(top('Sin fecha aquí')));
    });

    testWidgets('muestra fecha en español, nota de origen y omite fecha nula', (
      tester,
    ) async {
      await open(tester, [
        _recall('A', date: DateTime(2023, 3, 5), component: 'Airbag'),
        _recall('B', component: 'Frenos'),
      ]);
      expect(find.text(AppTexts.recallsSourceNote), findsOneWidget);
      expect(find.text('5 de marzo de 2023 · Campaña A'), findsOneWidget);
      expect(find.text('Campaña B'), findsOneWidget);
    });

    testWidgets(
      'resumen, consecuencia y remedio se expanden con el texto original',
      (tester) async {
        await open(tester, [
          _recall(
            'A',
            date: DateTime(2023, 3, 5),
            component: 'Airbag',
            summary: 'The airbag may not deploy.',
            consequence: 'Increased risk of injury.',
          ),
        ]);
        expect(find.text(AppTexts.recallSummaryTitle), findsOneWidget);
        expect(find.text(AppTexts.recallConsequenceTitle), findsOneWidget);
        // Sin remedio no hay bloque.
        expect(find.text(AppTexts.recallRemedyTitle), findsNothing);
        await tester.tap(find.text(AppTexts.recallSummaryTitle));
        await tester.pumpAndSettle();
        expect(find.text('The airbag may not deploy.'), findsOneWidget);
      },
    );
  });
}
