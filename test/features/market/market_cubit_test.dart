import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/market_test_support.dart';

class _FailingPreference implements MarketPreferenceDatasource {
  @override
  Future<String?> read() async => throw StateError('lectura rota');

  @override
  Future<void> write(String code) async => throw StateError('escritura rota');
}

void main() {
  group('Market', () {
    test('por código y mercado por defecto', () {
      expect(Market.fromCode('us'), Market.unitedStates);
      expect(Market.fromCode('mx'), Market.mexico);
      expect(Market.fromCode('xx'), isNull);
      expect(Market.fromCode(null), isNull);
      expect(Market.defaultMarket, Market.unitedStates);
    });
  });

  group('MarketCubit', () {
    test('sin nada guardado arranca en el mercado por defecto', () async {
      final cubit = MarketCubit(preference: FakeMarketPreference());
      expect(cubit.state.isRestored, isFalse);
      await cubit.restore();
      expect(cubit.state.market, Market.defaultMarket);
      expect(cubit.state.isRestored, isTrue);
    });

    test('restaura el mercado guardado', () async {
      final cubit = MarketCubit(preference: FakeMarketPreference(stored: 'mx'));
      await cubit.restore();
      expect(cubit.market, Market.mexico);
      expect(cubit.state.isRestored, isTrue);
    });

    test('un código desconocido o ilegible cae al por defecto', () async {
      final unknown = MarketCubit(
        preference: FakeMarketPreference(stored: 'zz'),
      );
      await unknown.restore();
      expect(unknown.market, Market.defaultMarket);
      final broken = MarketCubit(preference: _FailingPreference());
      await broken.restore();
      expect(broken.market, Market.defaultMarket);
      expect(broken.state.isRestored, isTrue);
    });

    test('al cambiar lo guarda y otra instancia lo restaura', () async {
      final preference = FakeMarketPreference();
      final cubit = MarketCubit(preference: preference);
      await cubit.restore();
      await cubit.select(Market.mexico);
      expect(cubit.market, Market.mexico);
      expect(preference.writes, ['mx']);
      final reopened = MarketCubit(preference: preference);
      await reopened.restore();
      expect(reopened.market, Market.mexico);
    });

    test('elegir el mercado activo no emite ni guarda', () async {
      final preference = FakeMarketPreference();
      final cubit = MarketCubit(preference: preference);
      await cubit.restore();
      final emitted = <MarketState>[];
      cubit.stream.listen(emitted.add);
      await cubit.select(Market.unitedStates);
      expect(emitted, isEmpty);
      expect(preference.writes, isEmpty);
    });

    test('si no puede guardar, el cambio vale en la sesión', () async {
      final cubit = MarketCubit(preference: _FailingPreference());
      await cubit.restore();
      await cubit.select(Market.mexico);
      expect(cubit.market, Market.mexico);
    });
  });
}
