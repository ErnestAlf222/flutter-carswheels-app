import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

// Un host con scroll y la consulta cambiante, como la hoja del selector.
class _Host extends StatefulWidget {
  const _Host({this.disableAnimations = false});

  final bool disableAnimations;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  // Único estado: la consulta que se le pasa al aviso.
  String query = '';
  Key hintKey = UniqueKey();

  void reopen() => setState(() => hintKey = UniqueKey());

  void setQuery(String value) => setState(() => query = value);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: widget.disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ComparePickerHintWidget(key: hintKey, query: query),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 3000)),
          ],
        ),
      ),
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final hint = find.text(AppTexts.comparePickerHint);
  const visible = Duration(
    milliseconds: CompareConfig.pickerHintVisibleMilliseconds,
  );

  testWidgets('aparece con su texto y su ícono de información', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump(const Duration(milliseconds: 400));
    expect(hint, findsOneWidget);
    expect(find.byIcon(Symbols.info), findsOneWidget);
    expect(find.byIcon(Symbols.close), findsOneWidget);
    await tester.pump(visible);
    await tester.pumpAndSettle();
  });

  testWidgets('entra con fundido y desplazamiento y se pliega por tiempo', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host());
    // Al inicio de la entrada aún es casi transparente.
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(ComparePickerHintWidget),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(0.5));
    await tester.pump(const Duration(milliseconds: 400));
    expect(hint, findsOneWidget);

    // Antes del tiempo sigue; pasado el tiempo se pliega con animación.
    await tester.pump(visible - const Duration(seconds: 1));
    expect(hint, findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(
      const Duration(
        milliseconds: CompareConfig.pickerHintCollapseMilliseconds,
      ),
    );
    expect(hint, findsNothing);
  });

  testWidgets('se pliega al escribir', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump(const Duration(milliseconds: 400));
    final host = tester.state<_HostState>(find.byType(_Host));
    // Un cambio de consulta cuenta como que el usuario ya empezó.
    host.setQuery('c');
    await tester.pumpAndSettle();
    expect(hint, findsNothing);
  });

  testWidgets('se pliega con la x', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Symbols.close));
    await tester.pumpAndSettle();
    expect(hint, findsNothing);
  });

  testWidgets('se pliega cuando el usuario hace scroll', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(hint, findsNothing);
  });

  testWidgets('no vuelve mientras siga abierta, sí al abrirse otra vez', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Symbols.close));
    await tester.pumpAndSettle();
    final host = tester.state<_HostState>(find.byType(_Host));
    // Reconstruir con otra consulta no lo muestra de nuevo.
    host.setQuery('');
    await tester.pumpAndSettle();
    expect(hint, findsNothing);
    // Una hoja nueva (otro widget) vuelve a mostrarlo.
    host.reopen();
    await tester.pump(const Duration(milliseconds: 400));
    expect(hint, findsOneWidget);
    await tester.pump(visible);
    await tester.pumpAndSettle();
  });

  testWidgets('con disableAnimations aparece y se va sin animar', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host(disableAnimations: true));
    // Un solo cuadro: ya está completo, sin fundido ni AnimatedSize.
    expect(hint, findsOneWidget);
    expect(find.byType(AnimatedSize), findsNothing);
    expect(find.byType(Opacity), findsNothing);
    await tester.tap(find.byIcon(Symbols.close));
    await tester.pump();
    expect(hint, findsNothing);
    expect(tester.takeException(), isNull);
  });
}
