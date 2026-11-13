import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  testWidgets('el nombre aparece en mayúsculas y mide 280 de alto', (
    tester,
  ) async {
    await tester.pumpWidget(
      detailHost(DetailHeroHeaderWidget(args: testArgs(groupName: 'Corolla'))),
    );
    expect(find.text('COROLLA'), findsOneWidget);
    expect(
      tester.getSize(find.byType(DetailHeroHeaderWidget)).height,
      UiConfig.detailHeroHeight,
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('el botón de volver está a 20 del borde y mide 48', (
    tester,
  ) async {
    await tester.pumpWidget(
      detailHost(DetailHeroHeaderWidget(args: testArgs())),
    );
    final header = tester.getRect(find.byType(DetailHeroHeaderWidget));
    final back = tester.getRect(find.byIcon(Symbols.chevron_left));
    expect(
      back.center.dx - header.left,
      UiConfig.detailCircleButtonInset + UiConfig.detailCircleButtonSize / 2,
    );
    final button = find.ancestor(
      of: find.byIcon(Symbols.chevron_left),
      matching: find.byType(SizedBox),
    );
    expect(tester.getSize(button.first), const Size(48, 48));
  });

  testWidgets('la zona alta recorta lo que se pinta fuera de sus 280', (
    tester,
  ) async {
    await tester.pumpWidget(
      detailHost(DetailHeroHeaderWidget(args: testArgs())),
    );
    final stack = tester.widget<Stack>(
      find
          .descendant(
            of: find.byType(DetailHeroHeaderWidget),
            matching: find.byType(Stack),
          )
          .first,
    );
    expect(stack.clipBehavior, Clip.hardEdge);
  });

  testWidgets('volver llama a pop', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('inicio')),
        GoRoute(
          path: '/a',
          builder: (_, _) =>
              Scaffold(body: DetailHeroHeaderWidget(args: testArgs())),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<BrandLogosCubit>.value(
        value: buildMockBrandLogosCubit(),
        child: BlocProvider<DetailGalleryCubit>.value(
          value: buildMockGalleryCubit(),
          child: RepositoryProvider<PhotoPrefetcher>.value(
            value: const PhotoPrefetcher(),
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/a'));
    await tester.pumpAndSettle();
    expect(find.byType(DetailHeroHeaderWidget), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(AppTexts.backLabel));
    await tester.pumpAndSettle();
    expect(find.text('inicio'), findsOneWidget);
    expect(find.byType(DetailHeroHeaderWidget), findsNothing);
  });

  testWidgets('arriba ya no hay corazón de favoritos', (tester) async {
    await tester.pumpWidget(
      detailHost(DetailHeroHeaderWidget(args: testArgs())),
    );
    expect(find.byIcon(Symbols.favorite), findsNothing);
    expect(find.bySemanticsLabel(AppTexts.addToFavoritesLabel), findsNothing);
  });

  testWidgets('un nombre largo con textScaler 2 no desborda', (tester) async {
    await tester.pumpWidget(
      detailHost(
        DetailHeroHeaderWidget(
          args: testArgs(groupName: 'Mustang Shelby GT500 Convertible Premium'),
        ),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
