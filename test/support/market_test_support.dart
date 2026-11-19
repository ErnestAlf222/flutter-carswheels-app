import 'package:cars_wheels_app/features/market/market.dart';

/// Preferencia de mercado en memoria que guarda lo escrito.
class FakeMarketPreference implements MarketPreferenceDatasource {
  FakeMarketPreference({this.stored});

  String? stored;
  final List<String> writes = [];

  @override
  Future<String?> read() async => stored;

  @override
  Future<void> write(String code) async {
    stored = code;
    writes.add(code);
  }
}

/// Cubit de mercado con memoria; arranca en [initial] ya restaurado.
MarketCubit buildMarketCubit({
  Market initial = Market.unitedStates,
  FakeMarketPreference? preference,
}) {
  final cubit = MarketCubit(
    preference: preference ?? FakeMarketPreference(stored: initial.code),
  );
  // Sin esperar: la lectura en memoria termina antes del primer cuadro.
  cubit.restore();
  return cubit;
}
