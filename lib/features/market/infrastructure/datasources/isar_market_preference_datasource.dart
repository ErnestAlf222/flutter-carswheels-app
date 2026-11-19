import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/domain/datasources/market_preference_datasource.dart';
import 'package:cars_wheels_app/features/market/infrastructure/models/market_preference_model.dart';

/// Preferencia de mercado guardada en Isar.
class IsarMarketPreferenceDatasource implements MarketPreferenceDatasource {
  const IsarMarketPreferenceDatasource(this.isar);

  final Isar isar;

  @override
  Future<String?> read() async {
    final model = await isar.marketPreferenceModels.get(
      MarketConfig.preferenceRecordId,
    );
    return model?.marketCode;
  }

  @override
  Future<void> write(String code) {
    return isar.writeTxn(
      () => isar.marketPreferenceModels.put(
        MarketPreferenceModel(marketCode: code),
      ),
    );
  }
}
