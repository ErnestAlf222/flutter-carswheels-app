import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/photos_test_support.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget card(String name, {double width = 300, int versions = 1}) =>
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PhotosCubit>.value(value: buildMockPhotosCubit()),
            BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(),
            ),
          ],
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: ModelCardWidget(
                  group: ModelGroupEntity(
                    name: name,
                    variants: [
                      for (int i = 0; i < versions; i++)
                        ModelEntity(name: '$name $i'),
                    ],
                  ),
                  brand: 'Honda',
                  year: 2020,
                  index: 0,
                ),
              ),
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

  testWidgets('con varias versiones muestra el conteo bajo el nombre', (
    tester,
  ) async {
    await tester.pumpWidget(card('Camry', versions: 9));
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.versionsCountLabel(9)), findsOneWidget);
    final nameRect = tester.getRect(find.text('Camry'));
    final versionsRect = tester.getRect(find.text('9 versiones'));
    expect(versionsRect.top, greaterThanOrEqualTo(nameRect.bottom));
  });

  testWidgets('con una sola versión no muestra la línea de versiones', (
    tester,
  ) async {
    await tester.pumpWidget(card('Civic'));
    await tester.pumpAndSettle();
    expect(find.textContaining('versi'), findsNothing);
  });

  testWidgets('la foto mide 104 por 72', (tester) async {
    await tester.pumpWidget(card('Civic'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(ModelPhotoWidget)),
      const Size(UiConfig.modelPhotoWidth, UiConfig.modelPhotoHeight),
    );
  });

  testWidgets(
    'la tarjeta usa el relleno, el radio y el espacio de la maqueta',
    (tester) async {
      await tester.pumpWidget(card('Civic'));
      await tester.pumpAndSettle();
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ModelCardWidget),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        container.padding,
        const EdgeInsets.fromLTRB(
          UiConfig.modelCardLeftPadding,
          AppSpacing.xs,
          UiConfig.modelCardRightPadding,
          AppSpacing.xs,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.card);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.card));
      final photoRect = tester.getRect(find.byType(ModelPhotoWidget));
      final textRect = tester.getRect(find.text('Civic'));
      expect(textRect.left - photoRect.right, UiConfig.modelCardGap);
    },
  );

  testWidgets('la foto recibe la marca, el modelo y el año de la tarjeta', (
    tester,
  ) async {
    await tester.pumpWidget(card('Civic 4Dr'));
    await tester.pumpAndSettle();
    final photo = tester.widget<ModelPhotoWidget>(
      find.byType(ModelPhotoWidget),
    );
    expect(photo.brand, 'Honda');
    expect(photo.model, 'Civic 4Dr');
    expect(photo.year, 2020);
    expect(photo.width, UiConfig.modelPhotoWidth);
    expect(photo.height, UiConfig.modelPhotoHeight);
    expect(photo.borderRadius, AppRadii.tile);
  });
}
