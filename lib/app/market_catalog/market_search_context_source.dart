import 'dart:async';

import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Mercado y año vigentes para la búsqueda, a partir de MarketCubit y CatalogCubit.
///
/// Mientras el catálogo se recarga por un cambio de mercado no hay alcance:
/// el año que aún guarda CatalogCubit pertenece al mercado anterior.
class MarketSearchContextSource implements SearchContextSource {
  MarketSearchContextSource({required this.market, required this.catalog})
    : _lastMarket = market.market {
    _scope = _compute();
    _marketSubscription = market.stream.listen(_onMarketState);
    _catalogSubscription = catalog.stream.listen(_onCatalogState);
  }

  final MarketCubit market;
  final CatalogCubit catalog;

  final StreamController<SearchScopeEntity?> _changes =
      StreamController<SearchScopeEntity?>.broadcast();
  late final StreamSubscription<MarketState> _marketSubscription;
  late final StreamSubscription<CatalogState> _catalogSubscription;

  Market _lastMarket;
  SearchScopeEntity? _scope;

  // Verdadero entre el cambio de mercado y el inicio de la recarga del catálogo.
  bool _catalogStale = false;

  @override
  SearchScopeEntity? get scope => _scope;

  @override
  Stream<SearchScopeEntity?> get scopeChanges => _changes.stream;

  void _onMarketState(MarketState state) {
    if (state.market == _lastMarket) return;
    _lastMarket = state.market;
    _catalogStale = true;
    _publish();
  }

  void _onCatalogState(CatalogState state) {
    // La recarga ya empezó: lo que llegue después es del mercado nuevo.
    if (state is CatalogLoading || state is CatalogInitial) {
      _catalogStale = false;
    }
    _publish();
  }

  SearchScopeEntity? _compute() {
    final state = catalog.state;
    if (_catalogStale || state is! CatalogLoaded) return null;
    return SearchScopeEntity(marketCode: _lastMarket.code, year: state.year);
  }

  void _publish() {
    final next = _compute();
    if (next == _scope) return;
    _scope = next;
    if (!_changes.isClosed) _changes.add(next);
  }

  @override
  Future<void> close() async {
    await _marketSubscription.cancel();
    await _catalogSubscription.cancel();
    await _changes.close();
  }
}
