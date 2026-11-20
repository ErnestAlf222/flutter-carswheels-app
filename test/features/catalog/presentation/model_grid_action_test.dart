import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/class_translator_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/summaries_test_support.dart';
import '../../../support/tall_view_test_support.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(useTallPhoneView);

  // Tres tarjetas: sin acción, con botón y con pastilla de "ya está".
  Widget grid(
    double textScale, {
    required bool reserve,
    required List<Widget?> actions,
    required VoidCallback onCardTap,
  }) {
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
            BlocProvider<PhotosCubit>.value(value: buildMockPhotosCubit()),
            BlocProvider<SummariesCubit>.value(
              value: buildMockSummariesCubit(),
            ),
            BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(),
            ),
          ],
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiConfig.pageHorizontalPadding,
                  ),
                  sliver: ModelGridSliver(
                    showBrandLabel: true,
                    reserveActionRow: reserve,
                    delegate: SliverChildListDelegate([
                      for (final (index, action) in actions.indexed)
                        ModelGridCardWidget(
                          group: ModelGroupEntity(
                            name: index == 0
                                ? 'Un nombre de modelo muy largo que ocupa dos líneas'
                                : 'Civic $index',
                            variants: const [],
                          ),
                          brand: 'Honda',
                          year: 2020,
                          index: index,
                          animateEntry: false,
                          showBrandLabel: true,
                          footerAction: action,
                          onTap: onCardTap,
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('sin acción la celda mide lo de siempre', (tester) async {
    await tester.pumpWidget(
      grid(1.0, reserve: false, actions: const [null, null], onCardTap: () {}),
    );
    await tester.pumpAndSettle();
    final size = tester.getSize(find.byType(ModelGridCardWidget).first);
    expect(
      size.height,
      ModelGridMetrics.cellHeight(
        size.width,
        TextScaler.noScaling,
        showBrandLabel: true,
      ),
    );
    expect(find.byType(ComparePickerButtonWidget), findsNothing);
  });

  for (final scale in [1.0, 1.3, 1.5]) {
    testWidgets(
      'con botón, con pastilla y sin acción miden igual con escala $scale',
      (tester) async {
        final taps = <String>[];
        await tester.pumpWidget(
          grid(
            scale,
            reserve: true,
            actions: [
              const ComparePickerButtonWidget(
                vehicleName: 'Honda Civic',
                isAdded: false,
              ),
              const ComparePickerButtonWidget(
                vehicleName: 'Honda Civic',
                isAdded: true,
              ),
              null,
              ComparePickerButtonWidget(
                vehicleName: 'Honda Civic',
                isAdded: false,
                onTap: () => taps.add('botón'),
              ),
            ],
            onCardTap: () => taps.add('tarjeta'),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final cards = find.byType(ModelGridCardWidget);
        final sizes = {
          for (final i in [0, 1, 2, 3]) tester.getSize(cards.at(i)),
        };
        // Misma altura con o sin acción, y sale de la fórmula con la reserva.
        expect(sizes, hasLength(1));
        expect(
          sizes.single.height,
          ModelGridMetrics.cellHeight(
            sizes.single.width,
            TextScaler.linear(scale),
            showBrandLabel: true,
            reserveActionRow: true,
          ),
        );
        // El botón no propaga el toque a la tarjeta.
        await tester.ensureVisible(
          find.text(AppTexts.comparePickerAddLabel).last,
        );
        await tester.tap(find.text(AppTexts.comparePickerAddLabel).last);
        expect(taps, ['botón']);
        // La pastilla no responde y tampoco deja pasar el toque a la tarjeta.
        await tester.tap(find.text(AppTexts.comparePickerAddedLabel));
        expect(taps, ['botón']);
      },
    );
  }
}
