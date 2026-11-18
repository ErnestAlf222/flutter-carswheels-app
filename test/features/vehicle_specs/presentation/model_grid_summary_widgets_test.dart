import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/class_translator_test_support.dart';
import '../../../support/summaries_test_support.dart';

GroupSummaryEntity _summary({
  double? min,
  double? max,
  List<EngineKind> kinds = const [],
  bool electric = false,
}) => GroupSummaryEntity(
  vehicleClass: 'Midsize Cars',
  minKmPerLiter: min,
  maxKmPerLiter: max,
  hasElectric: electric,
  hasPluginHybrid: false,
  variantCount: 2,
  engineKinds: kinds,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final key = summaryKeyFor('Honda', 'Civic', 2020);

  Widget host({required Widget child, SummarySlot? slot, bool still = false}) {
    return MaterialApp(
      builder: (context, content) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: still),
        child: content!,
      ),
      home: withClassTranslator(
        BlocProvider<SummariesCubit>.value(
          value: buildMockSummariesCubit(slots: {key: ?slot}),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  const badge = EngineBadgeWidget(
    brand: 'Honda',
    groupName: 'Civic',
    year: 2020,
  );
  const classLine = ModelClassTextWidget(
    brand: 'Honda',
    groupName: 'Civic',
    year: 2020,
  );
  const consumption = ModelConsumptionChipWidget(
    brand: 'Honda',
    groupName: 'Civic',
    year: 2020,
  );

  // Ambos widgets reciben su alto del padre, como en la tarjeta.
  Widget row(Widget child) => SizedBox(height: 32, width: 220, child: child);

  group('clase y consumo', () {
    testWidgets('gasolina muestra la clase y la cifra con km/l combinado', (
      tester,
    ) async {
      final slot = SummaryFound(_summary(min: 7.2, max: 10.4));
      await tester.pumpWidget(host(child: row(classLine), slot: slot));
      await tester.pumpAndSettle();
      expect(find.text('Mediano'), findsOneWidget);
      await tester.pumpWidget(host(child: row(consumption), slot: slot));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          '7–10 ${AppTexts.consumptionUnitShortLabel} '
          '${AppTexts.consumptionCombinedLabel}',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('el consumo ocupa una sola línea aun con cifra larga', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: row(consumption),
          slot: SummaryFound(_summary(min: 7.2, max: 10.4)),
        ),
      );
      await tester.pumpAndSettle();
      final chip = tester.getSize(find.byType(DecoratedBox).last);
      expect(chip.height, 32);
    });

    testWidgets('eléctrico muestra su etiqueta y nunca km/l', (tester) async {
      await tester.pumpWidget(
        host(
          child: row(consumption),
          slot: SummaryFound(
            _summary(electric: true, kinds: const [EngineKind.electric]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppTexts.electricLabel), findsOneWidget);
      expect(find.textContaining('km/l', findRichText: true), findsNothing);
    });

    testWidgets('dato ausente se muestra como guion en ambos', (tester) async {
      final slot = SummaryFound(_summary(min: null, max: null));
      await tester.pumpWidget(host(child: row(consumption), slot: slot));
      await tester.pumpAndSettle();
      expect(find.text(AppTexts.missingValueLabel), findsOneWidget);
    });

    testWidgets('cargando muestra una barra de esqueleto por fila', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: Column(children: [row(classLine), row(consumption)]),
          slot: const SummaryLoading(),
          still: true,
        ),
      );
      expect(find.byType(SkeletonBarWidget), findsNWidgets(2));
    });
  });

  group('insignia de motorización', () {
    testWidgets('eléctrico muestra un rayo verde', (tester) async {
      await tester.pumpWidget(
        host(
          child: badge,
          slot: SummaryFound(_summary(kinds: const [EngineKind.electric])),
          still: true,
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Symbols.bolt));
      expect(icon.color, AppColors.engineElectric);
    });

    testWidgets('muestra como máximo 3 íconos, electrificados primero', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: badge,
          slot: SummaryFound(
            _summary(
              kinds: const [
                EngineKind.electric,
                EngineKind.pluginHybrid,
                EngineKind.hybrid,
                EngineKind.diesel,
              ],
            ),
          ),
          still: true,
        ),
      );
      expect(find.byType(Icon), findsNWidgets(ModelGridConfig.maxEngineBadges));
      expect(find.byIcon(Symbols.bolt), findsOneWidget);
      expect(find.byIcon(Symbols.local_gas_station), findsNothing);
    });

    testWidgets('diésel es ámbar y hidrógeno una gota azul', (tester) async {
      await tester.pumpWidget(
        host(
          child: badge,
          slot: SummaryFound(
            _summary(kinds: const [EngineKind.hydrogen, EngineKind.diesel]),
          ),
          still: true,
        ),
      );
      expect(
        tester.widget<Icon>(find.byIcon(Symbols.water_drop)).color,
        AppColors.engineHydrogen,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Symbols.local_gas_station)).color,
        AppColors.engineDiesel,
      );
    });

    testWidgets('lleva etiqueta de accesibilidad con los tipos', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          child: badge,
          slot: SummaryFound(
            _summary(kinds: const [EngineKind.electric, EngineKind.gasoline]),
          ),
          still: true,
        ),
      );
      expect(
        find.bySemanticsLabel(
          AppTexts.engineBadgeSemanticLabel([
            AppTexts.electricLabel,
            AppTexts.gasolineLabel,
          ]),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('salta una sola vez y termina en escala 1', (tester) async {
      await tester.pumpWidget(
        host(
          child: badge,
          slot: SummaryFound(_summary(kinds: const [EngineKind.electric])),
        ),
      );
      await tester.pump(
        const Duration(
          milliseconds: ModelGridConfig.badgeBounceMilliseconds ~/ 2,
        ),
      );
      final peak = tester.widget<Transform>(
        find.descendant(
          of: find.byType(EngineBadgeWidget),
          matching: find.byType(Transform),
        ),
      );
      expect(peak.transform.getMaxScaleOnAxis(), greaterThan(1));
      await tester.pumpAndSettle();
      final end = tester.widget<Transform>(
        find.descendant(
          of: find.byType(EngineBadgeWidget),
          matching: find.byType(Transform),
        ),
      );
      expect(end.transform.getMaxScaleOnAxis(), closeTo(1, 0.001));
      // Una vez terminado no vuelve a animar.
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('con animaciones desactivadas no hay salto', (tester) async {
      await tester.pumpWidget(
        host(
          child: badge,
          slot: SummaryFound(_summary(kinds: const [EngineKind.electric])),
          still: true,
        ),
      );
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    });

    testWidgets('sin tipos no muestra nada', (tester) async {
      await tester.pumpWidget(
        host(child: badge, slot: SummaryFound(_summary()), still: true),
      );
      expect(find.byType(Icon), findsNothing);
    });
  });
}
