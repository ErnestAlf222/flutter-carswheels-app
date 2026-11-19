import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/core/core.dart';

part 'market_preference_model.g.dart';

/// Preferencia de mercado guardada en Isar; solo existe una fila.
@collection
class MarketPreferenceModel {
  MarketPreferenceModel({
    required this.marketCode,
    this.id = MarketConfig.preferenceRecordId,
  });

  final Id id;
  final String marketCode;
}
