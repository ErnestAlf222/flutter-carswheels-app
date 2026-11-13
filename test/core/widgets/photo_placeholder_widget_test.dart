import 'package:animate_do/animate_do.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

Widget _host(
  PhotoPlaceholderKind kind, {
  Widget? logo,
  bool compact = false,
  bool disableAnimations = false,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(
      body: SizedBox(
        width: 300,
        height: 200,
        child: PhotoPlaceholderWidget(kind: kind, logo: logo, compact: compact),
      ),
    ),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('loading', () {
    testWidgets('muestra el icono, el texto y el fondo tint', (tester) async {
      await tester.pumpWidget(_host(PhotoPlaceholderKind.loading));
      final icon = tester.widget<Icon>(find.byIcon(Symbols.photo_camera));
      expect(icon.size, UiConfig.photoLoadingIconSize);
      expect(find.text(AppTexts.photoLoadingLabel), findsOneWidget);
      expect(find.byType(Pulse), findsOneWidget);
      final box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(PhotoPlaceholderWidget),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, AppColors.tint);
    });

    testWidgets('compact omite el texto', (tester) async {
      await tester.pumpWidget(
        _host(PhotoPlaceholderKind.loading, compact: true),
      );
      expect(find.byIcon(Symbols.photo_camera), findsOneWidget);
      expect(find.text(AppTexts.photoLoadingLabel), findsNothing);
    });

    testWidgets('con disableAnimations no hay respiración', (tester) async {
      await tester.pumpWidget(
        _host(PhotoPlaceholderKind.loading, disableAnimations: true),
      );
      expect(find.byType(Pulse), findsNothing);
      expect(find.byIcon(Symbols.photo_camera), findsOneWidget);
    });
  });

  group('empty', () {
    testWidgets('muestra el logo, el texto y la semántica', (tester) async {
      await tester.pumpWidget(
        _host(
          PhotoPlaceholderKind.empty,
          logo: const SizedBox(key: Key('logo'), width: 10, height: 10),
        ),
      );
      expect(find.byKey(const Key('logo')), findsOneWidget);
      expect(find.text(AppTexts.noPhotoTitle), findsOneWidget);
      expect(find.byIcon(Symbols.no_photography), findsOneWidget);
      expect(find.byIcon(Symbols.directions_car), findsNothing);
      expect(
        find.bySemanticsLabel(AppTexts.noPhotoSemanticLabel),
        findsOneWidget,
      );
      expect(tester.widget<Text>(find.text(AppTexts.noPhotoTitle)).maxLines, 2);
    });

    testWidgets('sin logo usa el icono del auto', (tester) async {
      await tester.pumpWidget(_host(PhotoPlaceholderKind.empty));
      expect(find.byIcon(Symbols.directions_car), findsOneWidget);
    });

    testWidgets('compact omite el texto', (tester) async {
      await tester.pumpWidget(_host(PhotoPlaceholderKind.empty, compact: true));
      expect(find.text(AppTexts.noPhotoTitle), findsNothing);
      expect(find.byIcon(Symbols.directions_car), findsOneWidget);
    });
  });
}
