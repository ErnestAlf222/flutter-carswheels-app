import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  Widget card(PhotoEntity? photo, {String? heroTag = 'tag'}) => detailHost(
    Center(
      child: SizedBox(
        width: 300,
        child: DetailPhotoCardWidget(
          photo: photo,
          brandName: 'Toyota',
          heroTag: heroTag,
        ),
      ),
    ),
  );

  testWidgets('con foto hay dos imágenes y un Hero con la etiqueta', (
    tester,
  ) async {
    await tester.pumpWidget(card(testPhoto()));
    expect(find.byType(CachedNetworkImage), findsNWidgets(2));
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(tester.widget<Hero>(find.byType(Hero)).tag, 'tag');
    final box = tester.getSize(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxHeight == UiConfig.detailPhotoHeight,
      ),
    );
    expect(box.height, UiConfig.detailPhotoHeight);
  });

  testWidgets('la tarjeta es blanca, con esquinas de 32 y sombra suave', (
    tester,
  ) async {
    await tester.pumpWidget(card(testPhoto()));
    final container = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxHeight == UiConfig.detailPhotoHeight,
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.card);
    expect(decoration.borderRadius, BorderRadius.circular(32));
    expect(decoration.boxShadow, AppShadows.soft);
  });

  testWidgets('sin heroTag la foto no lleva Hero', (tester) async {
    await tester.pumpWidget(card(testPhoto(), heroTag: null));
    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('sin foto muestra el logo de respaldo y no hay crédito', (
    tester,
  ) async {
    await tester.pumpWidget(card(null));
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(Hero), findsNothing);
    expect(find.byType(BrandLogoWidget), findsOneWidget);
    expect(find.textContaining('Foto:'), findsNothing);
  });

  testWidgets('el crédito lleva autor y licencia', (tester) async {
    await tester.pumpWidget(card(testPhoto()));
    expect(find.text('Foto: Autora · CC BY 4.0'), findsOneWidget);
  });

  testWidgets('sin autor usa el texto de autor no indicado', (tester) async {
    await tester.pumpWidget(card(testPhoto(author: '  ')));
    expect(
      find.text(
        AppTexts.photoCreditLabel(AppTexts.authorMissingLabel, 'CC BY 4.0'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('la foto de referencia antepone la etiqueta', (tester) async {
    await tester.pumpWidget(card(testPhoto(isReference: true)));
    expect(
      find.text('${AppTexts.referencePhotoLabel} · Foto: Autora · CC BY 4.0'),
      findsOneWidget,
    );
  });

  testWidgets('el crédito va en una línea con elipsis y a 4 de la tarjeta', (
    tester,
  ) async {
    await tester.pumpWidget(card(testPhoto(author: 'A' * 200)));
    final text = tester.widget<Text>(find.textContaining('Foto:'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.textAlign, TextAlign.center);
    final cardBottom = tester
        .getRect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.constraints?.maxHeight == UiConfig.detailPhotoHeight,
          ),
        )
        .bottom;
    expect(
      tester.getRect(find.textContaining('Foto:')).top - cardBottom,
      UiConfig.detailCreditGap,
    );
  });
}
