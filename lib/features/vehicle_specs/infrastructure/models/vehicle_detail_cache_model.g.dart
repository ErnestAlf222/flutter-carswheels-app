// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_detail_cache_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetVehicleDetailCacheModelCollection on Isar {
  IsarCollection<VehicleDetailCacheModel> get vehicleDetailCacheModels =>
      this.collection();
}

const VehicleDetailCacheModelSchema = CollectionSchema(
  name: r'VehicleDetailCacheModel',
  id: 7764693965682847597,
  properties: {
    r'annualFuelCostUsd': PropertySchema(
      id: 0,
      name: r'annualFuelCostUsd',
      type: IsarType.long,
    ),
    r'cityKmPerLiter': PropertySchema(
      id: 1,
      name: r'cityKmPerLiter',
      type: IsarType.double,
    ),
    r'co2GramsPerKilometer': PropertySchema(
      id: 2,
      name: r'co2GramsPerKilometer',
      type: IsarType.double,
    ),
    r'combinedKmPerLiter': PropertySchema(
      id: 3,
      name: r'combinedKmPerLiter',
      type: IsarType.double,
    ),
    r'cylinders': PropertySchema(
      id: 4,
      name: r'cylinders',
      type: IsarType.long,
    ),
    r'displacementLiters': PropertySchema(
      id: 5,
      name: r'displacementLiters',
      type: IsarType.double,
    ),
    r'drive': PropertySchema(id: 6, name: r'drive', type: IsarType.string),
    r'electricConsumptionKwhPer100Kilometers': PropertySchema(
      id: 7,
      name: r'electricConsumptionKwhPer100Kilometers',
      type: IsarType.double,
    ),
    r'electricRangeKilometers': PropertySchema(
      id: 8,
      name: r'electricRangeKilometers',
      type: IsarType.double,
    ),
    r'emissionsScore': PropertySchema(
      id: 9,
      name: r'emissionsScore',
      type: IsarType.long,
    ),
    r'fuelScore': PropertySchema(
      id: 10,
      name: r'fuelScore',
      type: IsarType.long,
    ),
    r'fuelType': PropertySchema(
      id: 11,
      name: r'fuelType',
      type: IsarType.string,
    ),
    r'highwayKmPerLiter': PropertySchema(
      id: 12,
      name: r'highwayKmPerLiter',
      type: IsarType.double,
    ),
    r'hybridGasKmPerLiter': PropertySchema(
      id: 13,
      name: r'hybridGasKmPerLiter',
      type: IsarType.double,
    ),
    r'key': PropertySchema(id: 14, name: r'key', type: IsarType.string),
    r'make': PropertySchema(id: 15, name: r'make', type: IsarType.string),
    r'model': PropertySchema(id: 16, name: r'model', type: IsarType.string),
    r'powertrain': PropertySchema(
      id: 17,
      name: r'powertrain',
      type: IsarType.string,
    ),
    r'savedAtMillis': PropertySchema(
      id: 18,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
    r'totalRangeKilometers': PropertySchema(
      id: 19,
      name: r'totalRangeKilometers',
      type: IsarType.double,
    ),
    r'transmission': PropertySchema(
      id: 20,
      name: r'transmission',
      type: IsarType.string,
    ),
    r'vehicleClass': PropertySchema(
      id: 21,
      name: r'vehicleClass',
      type: IsarType.string,
    ),
    r'vehicleId': PropertySchema(
      id: 22,
      name: r'vehicleId',
      type: IsarType.long,
    ),
    r'year': PropertySchema(id: 23, name: r'year', type: IsarType.long),
  },

  estimateSize: _vehicleDetailCacheModelEstimateSize,
  serialize: _vehicleDetailCacheModelSerialize,
  deserialize: _vehicleDetailCacheModelDeserialize,
  deserializeProp: _vehicleDetailCacheModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _vehicleDetailCacheModelGetId,
  getLinks: _vehicleDetailCacheModelGetLinks,
  attach: _vehicleDetailCacheModelAttach,
  version: '3.4.1',
);

int _vehicleDetailCacheModelEstimateSize(
  VehicleDetailCacheModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.drive;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fuelType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.make.length * 3;
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.powertrain.length * 3;
  {
    final value = object.transmission;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.vehicleClass;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _vehicleDetailCacheModelSerialize(
  VehicleDetailCacheModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.annualFuelCostUsd);
  writer.writeDouble(offsets[1], object.cityKmPerLiter);
  writer.writeDouble(offsets[2], object.co2GramsPerKilometer);
  writer.writeDouble(offsets[3], object.combinedKmPerLiter);
  writer.writeLong(offsets[4], object.cylinders);
  writer.writeDouble(offsets[5], object.displacementLiters);
  writer.writeString(offsets[6], object.drive);
  writer.writeDouble(offsets[7], object.electricConsumptionKwhPer100Kilometers);
  writer.writeDouble(offsets[8], object.electricRangeKilometers);
  writer.writeLong(offsets[9], object.emissionsScore);
  writer.writeLong(offsets[10], object.fuelScore);
  writer.writeString(offsets[11], object.fuelType);
  writer.writeDouble(offsets[12], object.highwayKmPerLiter);
  writer.writeDouble(offsets[13], object.hybridGasKmPerLiter);
  writer.writeString(offsets[14], object.key);
  writer.writeString(offsets[15], object.make);
  writer.writeString(offsets[16], object.model);
  writer.writeString(offsets[17], object.powertrain);
  writer.writeLong(offsets[18], object.savedAtMillis);
  writer.writeDouble(offsets[19], object.totalRangeKilometers);
  writer.writeString(offsets[20], object.transmission);
  writer.writeString(offsets[21], object.vehicleClass);
  writer.writeLong(offsets[22], object.vehicleId);
  writer.writeLong(offsets[23], object.year);
}

VehicleDetailCacheModel _vehicleDetailCacheModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VehicleDetailCacheModel(
    annualFuelCostUsd: reader.readLongOrNull(offsets[0]),
    cityKmPerLiter: reader.readDoubleOrNull(offsets[1]),
    co2GramsPerKilometer: reader.readDoubleOrNull(offsets[2]),
    combinedKmPerLiter: reader.readDoubleOrNull(offsets[3]),
    cylinders: reader.readLongOrNull(offsets[4]),
    displacementLiters: reader.readDoubleOrNull(offsets[5]),
    drive: reader.readStringOrNull(offsets[6]),
    electricConsumptionKwhPer100Kilometers: reader.readDoubleOrNull(offsets[7]),
    electricRangeKilometers: reader.readDoubleOrNull(offsets[8]),
    emissionsScore: reader.readLongOrNull(offsets[9]),
    fuelScore: reader.readLongOrNull(offsets[10]),
    fuelType: reader.readStringOrNull(offsets[11]),
    highwayKmPerLiter: reader.readDoubleOrNull(offsets[12]),
    hybridGasKmPerLiter: reader.readDoubleOrNull(offsets[13]),
    id: id,
    key: reader.readString(offsets[14]),
    make: reader.readString(offsets[15]),
    model: reader.readString(offsets[16]),
    powertrain: reader.readString(offsets[17]),
    savedAtMillis: reader.readLong(offsets[18]),
    totalRangeKilometers: reader.readDoubleOrNull(offsets[19]),
    transmission: reader.readStringOrNull(offsets[20]),
    vehicleClass: reader.readStringOrNull(offsets[21]),
    vehicleId: reader.readLong(offsets[22]),
    year: reader.readLong(offsets[23]),
  );
  return object;
}

P _vehicleDetailCacheModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vehicleDetailCacheModelGetId(VehicleDetailCacheModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vehicleDetailCacheModelGetLinks(
  VehicleDetailCacheModel object,
) {
  return [];
}

void _vehicleDetailCacheModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  VehicleDetailCacheModel object,
) {}

extension VehicleDetailCacheModelByIndex
    on IsarCollection<VehicleDetailCacheModel> {
  Future<VehicleDetailCacheModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  VehicleDetailCacheModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<VehicleDetailCacheModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<VehicleDetailCacheModel?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(VehicleDetailCacheModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(VehicleDetailCacheModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<VehicleDetailCacheModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<VehicleDetailCacheModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension VehicleDetailCacheModelQueryWhereSort
    on QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QWhere> {
  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VehicleDetailCacheModelQueryWhere
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QWhereClause
        > {
  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterWhereClause
  >
  keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension VehicleDetailCacheModelQueryFilter
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QFilterCondition
        > {
  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  annualFuelCostUsdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'annualFuelCostUsd'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  annualFuelCostUsdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'annualFuelCostUsd'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  annualFuelCostUsdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'annualFuelCostUsd', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  annualFuelCostUsdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'annualFuelCostUsd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  annualFuelCostUsdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'annualFuelCostUsd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  annualFuelCostUsdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'annualFuelCostUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cityKmPerLiterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cityKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cityKmPerLiterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cityKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cityKmPerLiterEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cityKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cityKmPerLiterGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cityKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cityKmPerLiterLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cityKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cityKmPerLiterBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cityKmPerLiter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  co2GramsPerKilometerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'co2GramsPerKilometer'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  co2GramsPerKilometerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'co2GramsPerKilometer'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  co2GramsPerKilometerEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'co2GramsPerKilometer',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  co2GramsPerKilometerGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'co2GramsPerKilometer',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  co2GramsPerKilometerLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'co2GramsPerKilometer',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  co2GramsPerKilometerBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'co2GramsPerKilometer',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  combinedKmPerLiterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'combinedKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  combinedKmPerLiterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'combinedKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  combinedKmPerLiterEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'combinedKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  combinedKmPerLiterGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'combinedKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  combinedKmPerLiterLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'combinedKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  combinedKmPerLiterBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'combinedKmPerLiter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cylindersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cylinders'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cylindersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cylinders'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cylindersEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cylinders', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cylindersGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cylinders',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cylindersLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cylinders',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  cylindersBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cylinders',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  displacementLitersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'displacementLiters'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  displacementLitersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'displacementLiters'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  displacementLitersEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'displacementLiters',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  displacementLitersGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displacementLiters',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  displacementLitersLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displacementLiters',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  displacementLitersBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displacementLiters',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'drive'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'drive'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'drive',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'drive',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'drive',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'drive',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'drive',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'drive',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'drive',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'drive',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'drive', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  driveIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'drive', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricConsumptionKwhPer100KilometersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(
          property: r'electricConsumptionKwhPer100Kilometers',
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricConsumptionKwhPer100KilometersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'electricConsumptionKwhPer100Kilometers',
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricConsumptionKwhPer100KilometersEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'electricConsumptionKwhPer100Kilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricConsumptionKwhPer100KilometersGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'electricConsumptionKwhPer100Kilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricConsumptionKwhPer100KilometersLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'electricConsumptionKwhPer100Kilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricConsumptionKwhPer100KilometersBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'electricConsumptionKwhPer100Kilometers',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricRangeKilometersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'electricRangeKilometers'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricRangeKilometersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'electricRangeKilometers'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricRangeKilometersEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'electricRangeKilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricRangeKilometersGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'electricRangeKilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricRangeKilometersLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'electricRangeKilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  electricRangeKilometersBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'electricRangeKilometers',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  emissionsScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'emissionsScore'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  emissionsScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'emissionsScore'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  emissionsScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'emissionsScore', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  emissionsScoreGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'emissionsScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  emissionsScoreLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'emissionsScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  emissionsScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'emissionsScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fuelScore'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fuelScore'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fuelScore', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelScoreGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fuelScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelScoreLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fuelScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fuelScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fuelType'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fuelType'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fuelType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fuelType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fuelType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fuelType', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  fuelTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fuelType', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  highwayKmPerLiterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'highwayKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  highwayKmPerLiterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'highwayKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  highwayKmPerLiterEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'highwayKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  highwayKmPerLiterGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'highwayKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  highwayKmPerLiterLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'highwayKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  highwayKmPerLiterBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'highwayKmPerLiter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  hybridGasKmPerLiterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'hybridGasKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  hybridGasKmPerLiterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'hybridGasKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  hybridGasKmPerLiterEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hybridGasKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  hybridGasKmPerLiterGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hybridGasKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  hybridGasKmPerLiterLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hybridGasKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  hybridGasKmPerLiterBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hybridGasKmPerLiter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'make',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'make',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'make',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'make',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'make',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'make',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'make',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'make',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'make', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  makeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'make', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'model',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'model',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'model',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'model', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'model', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'powertrain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'powertrain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'powertrain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'powertrain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'powertrain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'powertrain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'powertrain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'powertrain',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'powertrain', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  powertrainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'powertrain', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  savedAtMillisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedAtMillis', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  savedAtMillisGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'savedAtMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  savedAtMillisLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'savedAtMillis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  savedAtMillisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'savedAtMillis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  totalRangeKilometersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalRangeKilometers'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  totalRangeKilometersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalRangeKilometers'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  totalRangeKilometersEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalRangeKilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  totalRangeKilometersGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalRangeKilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  totalRangeKilometersLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalRangeKilometers',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  totalRangeKilometersBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalRangeKilometers',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transmission'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transmission'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'transmission',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transmission',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transmission',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transmission',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'transmission',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'transmission',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'transmission',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'transmission',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transmission', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  transmissionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transmission', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'vehicleClass'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'vehicleClass'),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vehicleClass',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vehicleClass',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vehicleClass',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vehicleClass',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'vehicleClass',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'vehicleClass',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'vehicleClass',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'vehicleClass',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vehicleClass', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleClassIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vehicleClass', value: ''),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vehicleId', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vehicleId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vehicleId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  vehicleIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vehicleId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  yearEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'year', value: value),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  yearGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'year',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  yearLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'year',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VehicleDetailCacheModel,
    VehicleDetailCacheModel,
    QAfterFilterCondition
  >
  yearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'year',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension VehicleDetailCacheModelQueryObject
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QFilterCondition
        > {}

extension VehicleDetailCacheModelQueryLinks
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QFilterCondition
        > {}

extension VehicleDetailCacheModelQuerySortBy
    on QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QSortBy> {
  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByAnnualFuelCostUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFuelCostUsd', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByAnnualFuelCostUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFuelCostUsd', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCityKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCityKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCo2GramsPerKilometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2GramsPerKilometer', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCo2GramsPerKilometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2GramsPerKilometer', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCombinedKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCombinedKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCylinders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cylinders', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByCylindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cylinders', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByDisplacementLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displacementLiters', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByDisplacementLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displacementLiters', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByDrive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drive', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByDriveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drive', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByElectricConsumptionKwhPer100Kilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        r'electricConsumptionKwhPer100Kilometers',
        Sort.asc,
      );
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByElectricConsumptionKwhPer100KilometersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        r'electricConsumptionKwhPer100Kilometers',
        Sort.desc,
      );
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByElectricRangeKilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electricRangeKilometers', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByElectricRangeKilometersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electricRangeKilometers', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByEmissionsScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emissionsScore', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByEmissionsScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emissionsScore', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByFuelScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelScore', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByFuelScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelScore', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByFuelType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByFuelTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByHighwayKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highwayKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByHighwayKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highwayKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByHybridGasKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hybridGasKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByHybridGasKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hybridGasKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByMake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'make', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByMakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'make', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByPowertrain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByPowertrainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByTotalRangeKilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRangeKilometers', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByTotalRangeKilometersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRangeKilometers', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByTransmission() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transmission', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByTransmissionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transmission', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByVehicleClass() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByVehicleClassDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension VehicleDetailCacheModelQuerySortThenBy
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QSortThenBy
        > {
  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByAnnualFuelCostUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFuelCostUsd', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByAnnualFuelCostUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFuelCostUsd', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCityKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCityKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCo2GramsPerKilometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2GramsPerKilometer', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCo2GramsPerKilometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2GramsPerKilometer', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCombinedKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCombinedKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCylinders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cylinders', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByCylindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cylinders', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByDisplacementLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displacementLiters', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByDisplacementLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displacementLiters', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByDrive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drive', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByDriveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drive', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByElectricConsumptionKwhPer100Kilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        r'electricConsumptionKwhPer100Kilometers',
        Sort.asc,
      );
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByElectricConsumptionKwhPer100KilometersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        r'electricConsumptionKwhPer100Kilometers',
        Sort.desc,
      );
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByElectricRangeKilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electricRangeKilometers', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByElectricRangeKilometersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'electricRangeKilometers', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByEmissionsScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emissionsScore', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByEmissionsScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emissionsScore', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByFuelScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelScore', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByFuelScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelScore', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByFuelType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByFuelTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByHighwayKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highwayKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByHighwayKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highwayKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByHybridGasKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hybridGasKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByHybridGasKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hybridGasKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByMake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'make', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByMakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'make', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByPowertrain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByPowertrainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByTotalRangeKilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRangeKilometers', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByTotalRangeKilometersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRangeKilometers', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByTransmission() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transmission', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByTransmissionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transmission', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByVehicleClass() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByVehicleClassDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QAfterSortBy>
  thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension VehicleDetailCacheModelQueryWhereDistinct
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QDistinct
        > {
  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByAnnualFuelCostUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'annualFuelCostUsd');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByCityKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cityKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByCo2GramsPerKilometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'co2GramsPerKilometer');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByCombinedKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'combinedKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByCylinders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cylinders');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByDisplacementLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displacementLiters');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByDrive({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'drive', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByElectricConsumptionKwhPer100Kilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'electricConsumptionKwhPer100Kilometers');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByElectricRangeKilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'electricRangeKilometers');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByEmissionsScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emissionsScore');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByFuelScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fuelScore');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByFuelType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fuelType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByHighwayKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highwayKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByHybridGasKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hybridGasKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByMake({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'make', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByModel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByPowertrain({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'powertrain', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByTotalRangeKilometers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalRangeKilometers');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByTransmission({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transmission', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByVehicleClass({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleClass', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, VehicleDetailCacheModel, QDistinct>
  distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension VehicleDetailCacheModelQueryProperty
    on
        QueryBuilder<
          VehicleDetailCacheModel,
          VehicleDetailCacheModel,
          QQueryProperty
        > {
  QueryBuilder<VehicleDetailCacheModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int?, QQueryOperations>
  annualFuelCostUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'annualFuelCostUsd');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  cityKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cityKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  co2GramsPerKilometerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'co2GramsPerKilometer');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  combinedKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'combinedKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int?, QQueryOperations>
  cylindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cylinders');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  displacementLitersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displacementLiters');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String?, QQueryOperations>
  driveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'drive');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  electricConsumptionKwhPer100KilometersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'electricConsumptionKwhPer100Kilometers');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  electricRangeKilometersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'electricRangeKilometers');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int?, QQueryOperations>
  emissionsScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emissionsScore');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int?, QQueryOperations>
  fuelScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelScore');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String?, QQueryOperations>
  fuelTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelType');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  highwayKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highwayKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  hybridGasKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hybridGasKmPerLiter');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String, QQueryOperations>
  keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String, QQueryOperations>
  makeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'make');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String, QQueryOperations>
  modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String, QQueryOperations>
  powertrainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'powertrain');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, double?, QQueryOperations>
  totalRangeKilometersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalRangeKilometers');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String?, QQueryOperations>
  transmissionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transmission');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, String?, QQueryOperations>
  vehicleClassProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleClass');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int, QQueryOperations>
  vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }

  QueryBuilder<VehicleDetailCacheModel, int, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}
