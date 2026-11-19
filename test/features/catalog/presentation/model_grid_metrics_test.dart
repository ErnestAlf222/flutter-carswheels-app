import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/class_translator_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/summaries_test_support.dart';
import '../../../support/tall_view_test_support.dart';

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(useTallPhoneView);

  Widget grid(
    double textScale, {
    required Map<String, SummarySlot> slots,
    Map<String, PhotoSlot> photos = const {},
  }) {
    final models = _MockModelsCubit();
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: withClassTranslator(
        MultiBlocProvider(
          providers: [
            BlocProvider<ModelsCubit>.value(value: models),
            BlocProvider<PhotosCubit>.value(
              value: buildMockPhotosCubit(slots: photos),
            ),
            BlocProvider<SummariesCubit>.value(
              value: buildMockSummariesCubit(slots: slots),
            ),
            BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(),
            ),
          ],
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                ModelsSectionWidget(
                  brandName: 'Honda',
                  state: ModelsLoaded(
                    groups: [
                      for (final name in const [
                        'Civic',
                        'Un nombre de modelo '
                            'muy largo que ocupa dos líneas completas',
                      ])
                        ModelGroupEntity(
                          name: name,
                          variants: [ModelEntity(name: name)],
                        ),
                    ],
                    visibleCount: 2,
                    year: 2020,
                    brand: 'Honda',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  const gasoline = GroupSummaryEntity(
    vehicleClass: 'Midsize Cars',
    minKmPerLiter: 12.2,
    maxKmPerLiter: 15.4,
    hasElectric: false,
    hasPluginHybrid: false,
    variantCount: 1,
    engineKinds: [EngineKind.gasoline],
  );
  const electric = GroupSummaryEntity(
    vehicleClass: 'Midsize Cars',
    minKmPerLiter: null,
    maxKmPerLiter: null,
    hasElectric: true,
    hasPluginHybrid: false,
    variantCount: 1,
    engineKinds: [EngineKind.electric],
  );

  for (final scale in [1.0, 1.5]) {
    testWidgets('la celda cubre el texto sin desbordar con escala $scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        grid(
          scale,
          slots: {
            summaryKeyFor('Honda', 'Civic', 2020): const SummaryFound(gasoline),
            summaryKeyFor(
              'Honda',
              'Un nombre de modelo muy largo que ocupa dos líneas completas',
              2020,
            ): const SummaryFound(
              electric,
            ),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final cards = find.byType(ModelGridCardWidget);
      final first = tester.getSize(cards.at(0));
      final second = tester.getSize(cards.at(1));
      // Todas las tarjetas miden lo mismo y salen de la fórmula.
      expect(second, first);
      expect(
        first.height,
        ModelGridMetrics.cellHeight(first.width, TextScaler.linear(scale)),
      );
    });
  }

  testWidgets('gasolina muestra la cifra en su fila y EV sin km/l', (
    tester,
  ) async {
    await tester.pumpWidget(
      grid(
        1.0,
        slots: {
          summaryKeyFor('Honda', 'Civic', 2020): const SummaryFound(gasoline),
          summaryKeyFor(
            'Honda',
            'Un nombre de modelo muy largo que ocupa dos líneas completas',
            2020,
          ): const SummaryFound(
            electric,
          ),
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('12–15', findRichText: true), findsOneWidget);
    expect(find.textContaining('km/l', findRichText: true), findsOneWidget);
    expect(find.text(AppTexts.electricLabel), findsOneWidget);
  });

  testWidgets('la tarjeta sin foto muestra solo el logo, sin cámara tachada', (
    tester,
  ) async {
    await tester.pumpWidget(
      grid(
        1.0,
        slots: const {},
        photos: {photoKeyFor('Honda', 'Civic', 2020): const PhotoMissing()},
      ),
    );
    await tester.pump();
    expect(find.byIcon(Symbols.no_photography), findsNothing);
    expect(find.byIcon(Symbols.directions_car), findsWidgets);
  });
}
