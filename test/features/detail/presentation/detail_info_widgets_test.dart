import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  group('DetailTitleRowWidget', () {
    Widget row({String? classLabel, String name = 'Corolla'}) => detailHost(
      DetailTitleRowWidget(
        brand: 'Toyota',
        year: 2020,
        groupName: name,
        classLabel: classLabel,
      ),
    );

    testWidgets('muestra marca · año, nombre y la cápsula de clase', (
      tester,
    ) async {
      await tester.pumpWidget(row(classLabel: 'Compacto'));
      expect(find.text('TOYOTA · 2020'), findsOneWidget);
      expect(find.text('Corolla'), findsOneWidget);
      final chip = tester.widget<Container>(
        find.ancestor(
          of: find.text('Compacto'),
          matching: find.byType(Container),
        ),
      );
      final decoration = chip.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.tint);
      expect(decoration.borderRadius, BorderRadius.circular(14));
      expect(
        chip.padding,
        const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      );
    });

    testWidgets('sin clase no hay cápsula', (tester) async {
      await tester.pumpWidget(row());
      expect(find.text('Compacto'), findsNothing);
      expect(find.text('Corolla'), findsOneWidget);
    });

    testWidgets('un nombre largo con textScaler 2 no desborda', (tester) async {
      await tester.pumpWidget(
        detailHost(
          const DetailTitleRowWidget(
            brand: 'Mercedes-Benz',
            year: 2020,
            groupName: 'Sprinter 3500XD Crew Van High Roof Extended',
            classLabel: 'Van de pasajeros',
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('VersionSelectorButtonWidget', () {
    Widget button({int count = 3, bool enabled = true, VoidCallback? onTap}) =>
        detailHost(
          VersionSelectorButtonWidget(
            versionCount: count,
            descriptor: 'Automática · 4 cil · 2.0 L',
            enabled: enabled,
            onTap: onTap ?? () {},
          ),
        );

    testWidgets('con varias versiones muestra el conteo, el descriptor y el '
        'icono, y responde al toque', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(button(onTap: () => taps.add(1)));
      expect(find.text('Versión (3 disponibles)'), findsOneWidget);
      expect(find.text('Automática · 4 cil · 2.0 L'), findsOneWidget);
      expect(find.byIcon(Symbols.expand_more), findsOneWidget);
      expect(
        tester.getSize(find.byType(InkWell)).height,
        UiConfig.detailSelectorHeight,
      );
      await tester.tap(find.byType(InkWell));
      expect(taps, hasLength(1));
    });

    testWidgets(
      'con una versión dice 1 disponible, sin icono y sin respuesta',
      (tester) async {
        final taps = <int>[];
        await tester.pumpWidget(
          button(count: 1, enabled: false, onTap: () => taps.add(1)),
        );
        expect(find.text('Versión (1 disponible)'), findsOneWidget);
        expect(find.byIcon(Symbols.expand_more), findsNothing);
        await tester.tap(find.byType(InkWell), warnIfMissed: false);
        expect(taps, isEmpty);
      },
    );
  });

  group('DetailStatsCardWidget', () {
    Widget stats(VehicleDetailEntity detail, {double textScale = 1}) =>
        detailHost(DetailStatsCardWidget(detail: detail), textScale: textScale);

    testWidgets('combustión muestra km/l, costo anual y seguridad sin dato', (
      tester,
    ) async {
      await tester.pumpWidget(stats(testDetail()));
      expect(find.text('14.6'), findsOneWidget);
      expect(find.text(AppTexts.detailConsumptionCaption), findsOneWidget);
      expect(find.text(r'$1,750'), findsOneWidget);
      expect(find.text(AppTexts.detailAnnualCostCaption), findsOneWidget);
      expect(find.text(AppTexts.noDataLabel), findsOneWidget);
      expect(find.text(AppTexts.detailSafetyCaption), findsOneWidget);
    });

    testWidgets('la cifra usa Outfit 26 en color de enlace', (tester) async {
      await tester.pumpWidget(stats(testDetail()));
      final style = tester.widget<Text>(find.text('14.6')).style!;
      expect(style.fontSize, 26);
      expect(style.color, AppColors.link);
    });

    testWidgets('eléctrico muestra la etiqueta de motor', (tester) async {
      await tester.pumpWidget(
        stats(
          testDetail(
            powertrain: Powertrain.electric,
            combinedKmPerLiter: null,
            annualFuelCostUsd: 600,
          ),
        ),
      );
      expect(find.text(AppTexts.electricLabel), findsOneWidget);
      expect(find.text(AppTexts.detailPowertrainCaption), findsOneWidget);
      expect(find.text(r'$600'), findsOneWidget);
    });

    testWidgets('enchufable muestra Híbrido enchufable', (tester) async {
      await tester.pumpWidget(
        stats(
          testDetail(
            powertrain: Powertrain.pluginHybrid,
            combinedKmPerLiter: null,
          ),
        ),
      );
      expect(find.text(AppTexts.pluginHybridLabel), findsOneWidget);
      expect(find.text(AppTexts.detailPowertrainCaption), findsOneWidget);
    });

    testWidgets('hidrógeno con costo nulo muestra Hidrógeno y sin dato', (
      tester,
    ) async {
      await tester.pumpWidget(
        stats(
          testDetail(
            powertrain: Powertrain.fuelCell,
            combinedKmPerLiter: null,
            annualFuelCostUsd: null,
          ),
        ),
      );
      expect(find.text(AppTexts.hydrogenLabel), findsOneWidget);
      // Costo anual y seguridad.
      expect(find.text(AppTexts.noDataLabel), findsNWidgets(2));
    });

    testWidgets('todo nulo muestra sin dato en las tres cifras', (
      tester,
    ) async {
      await tester.pumpWidget(
        stats(
          testDetail(
            powertrain: Powertrain.other,
            combinedKmPerLiter: null,
            annualFuelCostUsd: null,
          ),
        ),
      );
      expect(find.text(AppTexts.noDataLabel), findsNWidgets(3));
      expect(find.text(AppTexts.detailConsumptionCaption), findsOneWidget);
    });

    testWidgets('con textScaler 2 y etiqueta larga no desborda', (
      tester,
    ) async {
      await tester.pumpWidget(
        stats(
          testDetail(
            powertrain: Powertrain.pluginHybrid,
            combinedKmPerLiter: null,
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('expone una sola etiqueta semántica con las tres cifras', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(stats(testDetail()));
      expect(
        find.bySemanticsLabel(RegExp('14.6, .*1,750, .*—, .*')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('DetailInfoRowsWidget', () {
    testWidgets('muestra los valores, la línea punteada y los recalls', (
      tester,
    ) async {
      await tester.pumpWidget(
        detailHost(
          const DetailInfoRowsWidget(
            classLabel: 'Compacto',
            fuelLabel: 'Gasolina regular',
            driveLabel: 'Tracción delantera',
            recallsLabel: '2',
          ),
        ),
      );
      expect(find.text(AppTexts.detailClassRowLabel), findsOneWidget);
      expect(find.text('Compacto'), findsOneWidget);
      expect(find.text('Gasolina regular'), findsOneWidget);
      expect(find.text('Tracción delantera'), findsOneWidget);
      expect(find.byType(DashedDividerWidget), findsNWidgets(3));
      expect(find.text(AppTexts.detailRecallsLabel), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Symbols.chevron_right), findsOneWidget);
    });

    testWidgets('los valores nulos muestran sin dato', (tester) async {
      await tester.pumpWidget(detailHost(const DetailInfoRowsWidget()));
      // Tres filas más recalls.
      expect(find.text(AppTexts.noDataLabel), findsNWidgets(4));
    });
  });

  group('DetailBottomBarWidget', () {
    testWidgets('el botón de comparar llama a onCompare', (tester) async {
      final compares = <int>[];
      await tester.pumpWidget(
        detailHost(DetailBottomBarWidget(onCompare: () => compares.add(1))),
      );
      expect(find.text(AppTexts.compareWithOtherLabel), findsOneWidget);
      expect(find.byIcon(Symbols.favorite), findsOneWidget);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      expect(compares, hasLength(1));
    });

    testWidgets('el corazón mide 60, separado 12 del botón', (tester) async {
      await tester.pumpWidget(
        detailHost(DetailBottomBarWidget(onCompare: () {})),
      );
      final heart = tester.getRect(
        find
            .ancestor(
              of: find.byIcon(Symbols.favorite),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(heart.size, const Size(60, 60));
      final button = tester.getRect(find.byType(GradientButton));
      expect(button.left - heart.right, UiConfig.detailBottomBarGap);
      expect(button.height, UiConfig.detailBottomBarHeight);
    });
  });

  group('DetailSkeletonWidget', () {
    testWidgets('muestra barras de esqueleto y ningún AppLoader', (
      tester,
    ) async {
      await tester.pumpWidget(detailHost(const DetailSkeletonWidget()));
      // Cápsula, botón de versión, tarjeta de cifras y tres filas.
      expect(find.byType(SkeletonBarWidget), findsNWidgets(6));
      expect(find.byType(AppLoader), findsNothing);
    });
  });
}
