import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _pageKey = Key('shell-page');

Widget _shell({double keyboard = 0}) => MediaQuery(
  data: MediaQueryData(
    disableAnimations: true,
    viewInsets: EdgeInsets.only(bottom: keyboard),
  ),
  child: MaterialApp(
    home: BlocProvider(
      create: (_) => SectionLoaderCubit(),
      child: const MainShellPage(
        location: RoutesConfig.home,
        child: SizedBox.expand(key: _pageKey),
      ),
    ),
  ),
);

Stack _bodyStack(WidgetTester tester) => tester.widget<Stack>(
  find.descendant(
    of: find.byType(MainShellPage),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Stack &&
          widget.children.any(
            (child) => child is NotificationListener<ScrollUpdateNotification>,
          ),
    ),
  ),
);

void main() {
  testWidgets('orden de capas: página, aviso de carga y menú al final', (
    tester,
  ) async {
    await tester.pumpWidget(_shell());
    final children = _bodyStack(tester).children;
    expect(children, hasLength(3));
    expect(children[0], isA<NotificationListener<ScrollUpdateNotification>>());
    final nav = children[2] as Positioned;
    expect(
      find.descendant(
        of: find.byWidget(nav),
        matching: find.byType(FloatingNavBar),
      ),
      findsOneWidget,
    );
    final shell = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(shell.backgroundColor, AppColors.background);
  });

  testWidgets('el menú flotante queda sobre el borde inferior', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_shell());
    final nav = tester.getRect(find.byType(FloatingNavBar));
    expect(nav.bottom, 600 - NavConfig.bottomMargin);
    expect(find.byType(FloatingNavBar).hitTestable(), findsOneWidget);
  });

  testWidgets('con el teclado abierto el menú se oculta', (tester) async {
    await tester.pumpWidget(_shell(keyboard: 300));
    expect(
      tester.widget<FloatingNavBar>(find.byType(FloatingNavBar)).visible,
      isFalse,
    );
    // El contenido conserva su lugar en el árbol.
    expect(find.byKey(_pageKey), findsOneWidget);
  });
}
