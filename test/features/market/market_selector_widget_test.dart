import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/market_test_support.dart';

Widget _host(MarketCubit cubit) => MaterialApp(
  home: BlocProvider<MarketCubit>.value(
    value: cubit,
    child: const Scaffold(body: Center(child: MarketSelectorWidget())),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('el selector cambia de mercado y lo guarda', (tester) async {
    final preference = FakeMarketPreference();
    final cubit = buildMarketCubit(preference: preference);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    expect(find.text('EE. UU.'), findsOneWidget);
    expect(find.text('México'), findsOneWidget);
    expect(cubit.market, Market.unitedStates);
    await tester.tap(find.text('México'));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.mexico);
    expect(preference.writes, ['mx']);
    await tester.tap(find.text('EE. UU.'));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.unitedStates);
  });

  testWidgets('cada segmento tiene etiqueta de accesibilidad', (tester) async {
    final cubit = buildMarketCubit(initial: Market.mexico);
    addTearDown(cubit.close);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    expect(find.bySemanticsLabel('Mercado México'), findsOneWidget);
    expect(find.bySemanticsLabel('Mercado EE. UU.'), findsOneWidget);
    expect(find.bySemanticsLabel('Mercado del catálogo'), findsOneWidget);
    handle.dispose();
  });
}
