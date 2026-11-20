import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/compare_test_support.dart';

const _pickerText = 'selector-de-vehiculo';

// Foto y logo de prueba: cajas con llave, sin red ni cubits.
final CompareSlotVisuals _visuals = CompareSlotVisuals(
  photoBuilder: (context, slot) =>
      ColoredBox(key: ValueKey('photo-${slot.modelName}'), color: Colors.grey),
  logoBuilder: (context, slot, size) => SizedBox(width: size, height: size),
);

// Ancho parecido al de la píldora real de mercado y año.
Widget _selector(BuildContext context) => const SizedBox(
  key: ValueKey('selector-de-prueba'),
  width: 170,
  height: MarketConfig.selectorHeight,
);

Finder get _dashedSlots => find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint && widget.foregroundPainter is DashedBorderPainter,
);

// Dos cuadros: el primero entrega el evento del cubit y el segundo lo pinta.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Finder get _filledSlots => find.byType(CompareFilledSlotWidget);

class _Harness {
  const _Harness({
    required this.cubit,
    required this.router,
    required this.store,
  });

  final CompareCubit cubit;
  final GoRouter router;
  final InMemoryCompareSelection store;
}

// Proveedores de la pantalla: selección, tabla y versiones, con fuentes falsas.
Widget _providers({
  required CompareCubit cubit,
  required CompareTableCubit table,
  required Widget child,
  FakeCompareVersionsSource? versions,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider<CompareVersionsSource>.value(
      value: versions ?? FakeCompareVersionsSource(),
    ),
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider<CompareCubit>.value(value: cubit),
      BlocProvider<CompareTableCubit>.value(value: table),
    ],
    child: child,
  ),
);

Future<_Harness> _pumpPage(
  WidgetTester tester, {
  List<CompareSlotEntity> initial = const [],
  double textScale = 1.0,
  Size size = const Size(360, 800),
  double topInset = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = InMemoryCompareSelection();
  await store.write('us', initial);
  final cubit = buildCompareCubit(
    selection: store,
    noticeDuration: const Duration(seconds: 30),
  );
  addTearDown(cubit.close);
  final table = buildCompareTableCubit(
    compare: cubit,
    vehicles: FakeCompareVehicleSource(),
  );
  addTearDown(table.close);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            ComparePage(selectorBuilder: _selector, visuals: _visuals),
      ),
      GoRoute(
        path: RoutesConfig.comparePicker,
        builder: (_, _) => const Text(_pickerText),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    _providers(
      cubit: cubit,
      table: table,
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
            padding: EdgeInsets.only(top: topInset),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return _Harness(cubit: cubit, router: router, store: store);
}

List<CompareSlotEntity> _slots(int count) => [
  compareSlot(model: 'Corolla'),
  compareSlot(model: 'Camry', brand: 'Toyota'),
  compareSlot(model: 'Sprinter Cargo Van Largo', brand: 'Mercedes-Benz'),
].take(count).toList();

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('vacío: encabezado, 3 espacios punteados y el único amarillo', (
    tester,
  ) async {
    await _pumpPage(tester);
    expect(find.byType(HeroHeaderWidget), findsOneWidget);
    expect(find.text(AppTexts.comparePageTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('selector-de-prueba')), findsOneWidget);
    expect(_dashedSlots, findsNWidgets(CompareConfig.maxSlots));
    expect(_filledSlots, findsNothing);
    expect(
      find.text(AppTexts.compareEmptyTitle(CompareConfig.maxSlots)),
      findsOneWidget,
    );
    expect(find.text(AppTexts.compareEmptyBody), findsOneWidget);
    expect(find.byType(AccentButton), findsOneWidget);
    expect(find.text(AppTexts.compareAddVehicleLabel), findsOneWidget);
    expect(find.text(AppTexts.compareClearLabel), findsNothing);
    expect(find.text(AppTexts.compareTableTitle), findsNothing);
  });

  testWidgets('el borde punteado se dibuja con trazo discontinuo', (
    tester,
  ) async {
    await _pumpPage(tester);
    final render = tester.renderObject<RenderBox>(_dashedSlots.first);
    // Primero el fondo de la tarjeta y encima el trazo discontinuo.
    expect(
      render,
      paints
        ..path(color: AppColors.surface)
        ..path(color: AppColors.dashedLine),
    );
    const painter = DashedBorderPainter(
      color: AppColors.dashedLine,
      strokeWidth: CompareConfig.slotBorderWidth,
      radius: CompareConfig.slotRadius,
      dashLength: CompareConfig.dashLength,
      gapLength: CompareConfig.dashGap,
    );
    expect(painter.shouldRepaint(painter), isFalse);
    expect(
      const DashedBorderPainter(
        color: AppColors.dashedLine,
        strokeWidth: 2,
        radius: CompareConfig.slotRadius,
        dashLength: CompareConfig.dashLength,
        gapLength: CompareConfig.dashGap,
      ).shouldRepaint(painter),
      isTrue,
    );
  });

  testWidgets('con 1 vehículo: ocupado + 2 libres, ayuda, botón y Limpiar', (
    tester,
  ) async {
    await _pumpPage(tester, initial: _slots(1));
    expect(_filledSlots, findsOneWidget);
    expect(_dashedSlots, findsNWidgets(2));
    expect(find.byKey(const ValueKey('photo-Corolla')), findsOneWidget);
    expect(find.text('Corolla'), findsOneWidget);
    expect(find.text('TOYOTA'), findsOneWidget);
    expect(find.text(AppTexts.compareOneVehicleBody), findsOneWidget);
    expect(find.byType(AccentButton), findsOneWidget);
    expect(find.text(AppTexts.compareClearLabel), findsOneWidget);
    expect(find.text(AppTexts.compareTableTitle), findsNothing);
  });

  testWidgets('con 2: la tabla comparativa, sin botón amarillo', (
    tester,
  ) async {
    await _pumpPage(tester, initial: _slots(2));
    expect(_filledSlots, findsNWidgets(2));
    expect(_dashedSlots, findsOneWidget);
    expect(find.text(AppTexts.compareTableTitle), findsOneWidget);
    expect(find.byType(AccentButton), findsNothing);
    expect(find.text(AppTexts.compareClearLabel), findsOneWidget);
  });

  testWidgets(
    'la banda fija de la barra de estado va primero y la tabla no la repite',
    (tester) async {
      await _pumpPage(tester, initial: _slots(2), topInset: 44);
      expect(find.byType(StatusBarBandSliver), findsOneWidget);
      expect(
        tester
            .getSize(
              find.descendant(
                of: find.byType(StatusBarBandSliver),
                matching: find.byType(ColoredBox),
              ),
            )
            .height,
        44,
      );
      final band = find.descendant(
        of: find.byType(StatusBarBandSliver),
        matching: find.byType(ColoredBox),
      );
      expect(tester.getTopLeft(band).dy, 0);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(band).dy, 0);
      // La banda de columnas se fija justo debajo de la de la barra de estado.
      final columns = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border is Border &&
            (widget.decoration as BoxDecoration).color == AppColors.background,
      );
      expect(columns, findsWidgets);
    },
  );

  testWidgets('con 3: sin espacios libres ni botón', (tester) async {
    await _pumpPage(tester, initial: _slots(3));
    expect(_filledSlots, findsNWidgets(3));
    expect(_dashedSlots, findsNothing);
    expect(find.text(AppTexts.compareTableTitle), findsOneWidget);
    expect(find.byType(AccentButton), findsNothing);
  });

  testWidgets('quitar con la x deja el espacio libre', (tester) async {
    await _pumpPage(tester, initial: _slots(2));
    await tester.tap(find.byIcon(Symbols.close).first);
    await tester.pump();
    await tester.pump();
    expect(_filledSlots, findsOneWidget);
    expect(find.text('Corolla'), findsNothing);
    expect(find.text('Camry'), findsOneWidget);
    // Con un solo vehículo ya no hay tabla.
    expect(find.text(AppTexts.compareTableTitle), findsNothing);
  });

  testWidgets('Limpiar vacía el comparador', (tester) async {
    final harness = await _pumpPage(tester, initial: _slots(3));
    await tester.tap(find.text(AppTexts.compareClearLabel));
    await tester.pump();
    await tester.pump();
    expect(_filledSlots, findsNothing);
    expect(_dashedSlots, findsNWidgets(3));
    expect(await harness.store.read('us'), isEmpty);
  });

  testWidgets('tocar un espacio libre o el botón abre el selector', (
    tester,
  ) async {
    final harness = await _pumpPage(tester, initial: _slots(1));
    await tester.tap(_dashedSlots.first);
    await tester.pumpAndSettle();
    expect(find.text(_pickerText), findsOneWidget);
    harness.router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppTexts.compareAddVehicleLabel));
    await tester.pumpAndSettle();
    expect(find.text(_pickerText), findsOneWidget);
  });

  testWidgets('mensaje de lleno y de "ya está"; no se duplica ni se pasa', (
    tester,
  ) async {
    final harness = await _pumpPage(tester, initial: _slots(3));
    await harness.cubit.add(compareSlot(model: 'Otro'));
    await _settle(tester);
    expect(find.text(AppTexts.compareFullNotice), findsOneWidget);
    await harness.cubit.add(compareSlot(model: 'Corolla'));
    await _settle(tester);
    expect(find.text(AppTexts.compareAlreadyAddedNotice), findsOneWidget);
    expect(find.text(AppTexts.compareFullNotice), findsNothing);
    expect(_filledSlots, findsNWidgets(3));
    expect(await harness.store.read('us'), hasLength(3));
    // Sin temporizadores pendientes al terminar la prueba.
    harness.cubit.dismissNotice();
  });

  testWidgets('el mensaje breve se retira solo', (tester) async {
    final harness = await _pumpPage(tester, initial: _slots(3));
    await harness.cubit.add(compareSlot(model: 'Otro'));
    await _settle(tester);
    expect(find.text(AppTexts.compareFullNotice), findsOneWidget);
    harness.cubit.dismissNotice();
    await _settle(tester);
    expect(find.text(AppTexts.compareFullNotice), findsNothing);
  });

  group('sin desbordes a 360 dp', () {
    for (final count in [0, 1, 2, 3]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('$count vehículos con texto x$scale', (tester) async {
          await _pumpPage(tester, initial: _slots(count), textScale: scale);
          expect(tester.takeException(), isNull);
          final width = tester.getSize(find.byType(ComparePage)).width;
          for (final finder in [_filledSlots, _dashedSlots]) {
            for (int i = 0; i < finder.evaluate().length; i++) {
              expect(
                tester.getRect(finder.at(i)).right,
                lessThanOrEqualTo(width),
              );
            }
          }
        });
      }
    }
  });

  testWidgets('el cambio de mercado muestra la selección de ese mercado', (
    tester,
  ) async {
    final market = FakeCompareMarketSource();
    final store = InMemoryCompareSelection();
    await store.write('us', [compareSlot(model: 'Corolla')]);
    await store.write('mx', [
      compareSlot(model: 'Versa', brand: 'Nissan', marketCode: 'mx'),
      compareSlot(model: 'Aveo', brand: 'Chevrolet', marketCode: 'mx'),
    ]);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = buildCompareCubit(selection: store, market: market);
    addTearDown(cubit.close);
    final table = buildCompareTableCubit(
      compare: cubit,
      vehicles: FakeCompareVehicleSource(),
    );
    addTearDown(table.close);
    await tester.pumpWidget(
      _providers(
        cubit: cubit,
        table: table,
        child: MaterialApp(
          home: ComparePage(
            selectorBuilder: (_) => const SizedBox(),
            visuals: _visuals,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Corolla'), findsOneWidget);
    // El encabezado es el mismo: solo cambian los espacios.
    final header = tester.element(find.byType(HeroHeaderWidget));
    market.switchTo('mx');
    await tester.pump();
    await tester.pump();
    expect(find.text('Versa'), findsOneWidget);
    expect(find.text('Corolla'), findsNothing);
    expect(tester.element(find.byType(HeroHeaderWidget)), same(header));
  });
}
