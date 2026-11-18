import 'package:cars_wheels_app/core/core.dart';

/// Recurso de CKAN tal como lo describe package_show.
typedef ConueeResourceModel = ({String id, String name, bool datastoreActive});

/// Respuesta de package_show: los recursos del conjunto de datos.
class ConueePackageModel {
  const ConueePackageModel({required this.resources});

  factory ConueePackageModel.fromJson(Object? data) {
    final result = data is Map<String, dynamic>
        ? data[ConueeConfig.resultKey]
        : null;
    final resources = result is Map<String, dynamic>
        ? result[ConueeConfig.resourcesKey]
        : null;
    if (resources is! List<dynamic>) {
      throw const ParsingFailure(ConueeConfig.unexpectedShapeMessage);
    }
    return ConueePackageModel(
      resources: [
        for (final item in resources)
          if (item is Map<String, dynamic> &&
              item[ConueeConfig.resourceIdKey] is String &&
              item[ConueeConfig.resourceNameKey] is String)
            (
              id: item[ConueeConfig.resourceIdKey] as String,
              name: item[ConueeConfig.resourceNameKey] as String,
              datastoreActive: item[ConueeConfig.datastoreActiveKey] == true,
            ),
      ],
    );
  }

  final List<ConueeResourceModel> resources;
}

/// Respuesta de datastore_search: total de filas y las filas de la página.
class ConueeRecordsModel {
  const ConueeRecordsModel({required this.total, required this.records});

  factory ConueeRecordsModel.fromJson(Object? data) {
    final result = data is Map<String, dynamic>
        ? data[ConueeConfig.resultKey]
        : null;
    final records = result is Map<String, dynamic>
        ? result[ConueeConfig.recordsKey]
        : null;
    final total = result is Map<String, dynamic>
        ? result[ConueeConfig.totalKey]
        : null;
    if (records is! List<dynamic> || total is! int) {
      throw const ParsingFailure(ConueeConfig.unexpectedShapeMessage);
    }
    return ConueeRecordsModel(
      total: total,
      records: [
        for (final item in records)
          if (item is Map<String, dynamic>) item,
      ],
    );
  }

  final int total;
  final List<Map<String, dynamic>> records;
}
