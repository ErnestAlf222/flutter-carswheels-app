import 'dart:convert';

import 'package:cars_wheels_app/core/config/compare_config.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Convierte la selección a JSON y de vuelta, y arma la clave de Isar.
class ComparePayloadMapper {
  const ComparePayloadMapper._();

  /// Clave versionada: prefijo, versión y código del mercado.
  static String keyFor(String marketCode) => [
    CompareConfig.storageKeyPrefix,
    CompareConfig.storageKeyVersion,
    marketCode,
  ].join(CompareConfig.storageKeySeparator);

  static String toPayload(List<CompareSlotEntity> slots) => jsonEncode({
    CompareConfig.payloadSlotsKey: [
      for (final slot in slots)
        {
          CompareConfig.payloadMarketKey: slot.marketCode,
          CompareConfig.payloadYearKey: slot.year,
          CompareConfig.payloadBrandKey: slot.brand,
          CompareConfig.payloadGroupKey: slot.groupKey,
          CompareConfig.payloadModelKey: slot.modelName,
          CompareConfig.payloadVersionKey: slot.versionKey,
        },
    ],
  });

  /// Lanza si el JSON no tiene la forma esperada; quien lee decide qué hacer.
  static List<CompareSlotEntity> fromPayload(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    return [
      for (final item in json[CompareConfig.payloadSlotsKey] as List<dynamic>)
        CompareSlotEntity(
          marketCode:
              (item as Map<String, dynamic>)[CompareConfig.payloadMarketKey]
                  as String,
          year: item[CompareConfig.payloadYearKey] as int,
          brand: item[CompareConfig.payloadBrandKey] as String,
          groupKey: item[CompareConfig.payloadGroupKey] as String,
          modelName: item[CompareConfig.payloadModelKey] as String,
          versionKey: item[CompareConfig.payloadVersionKey] as String?,
        ),
    ];
  }
}
