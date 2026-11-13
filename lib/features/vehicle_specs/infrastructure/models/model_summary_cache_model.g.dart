// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_summary_cache_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetModelSummaryCacheModelCollection on Isar {
  IsarCollection<ModelSummaryCacheModel> get modelSummaryCacheModels =>
      this.collection();
}

const ModelSummaryCacheModelSchema = CollectionSchema(
  name: r'ModelSummaryCacheModel',
  id: 8307758813119630361,
  properties: {
    r'combinedKmPerLiter': PropertySchema(
      id: 0,
      name: r'combinedKmPerLiter',
      type: IsarType.double,
    ),
    r'key': PropertySchema(id: 1, name: r'key', type: IsarType.string),
    r'powertrain': PropertySchema(
      id: 2,
      name: r'powertrain',
      type: IsarType.string,
    ),
    r'savedAtMillis': PropertySchema(
      id: 3,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
    r'vehicleClass': PropertySchema(
      id: 4,
      name: r'vehicleClass',
      type: IsarType.string,
    ),
  },

  estimateSize: _modelSummaryCacheModelEstimateSize,
  serialize: _modelSummaryCacheModelSerialize,
  deserialize: _modelSummaryCacheModelDeserialize,
  deserializeProp: _modelSummaryCacheModelDeserializeProp,
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

  getId: _modelSummaryCacheModelGetId,
  getLinks: _modelSummaryCacheModelGetLinks,
  attach: _modelSummaryCacheModelAttach,
  version: '3.4.1',
);

int _modelSummaryCacheModelEstimateSize(
  ModelSummaryCacheModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.powertrain.length * 3;
  {
    final value = object.vehicleClass;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _modelSummaryCacheModelSerialize(
  ModelSummaryCacheModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.combinedKmPerLiter);
  writer.writeString(offsets[1], object.key);
  writer.writeString(offsets[2], object.powertrain);
  writer.writeLong(offsets[3], object.savedAtMillis);
  writer.writeString(offsets[4], object.vehicleClass);
}

ModelSummaryCacheModel _modelSummaryCacheModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModelSummaryCacheModel(
    combinedKmPerLiter: reader.readDoubleOrNull(offsets[0]),
    id: id,
    key: reader.readString(offsets[1]),
    powertrain: reader.readString(offsets[2]),
    savedAtMillis: reader.readLong(offsets[3]),
    vehicleClass: reader.readStringOrNull(offsets[4]),
  );
  return object;
}

P _modelSummaryCacheModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _modelSummaryCacheModelGetId(ModelSummaryCacheModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _modelSummaryCacheModelGetLinks(
  ModelSummaryCacheModel object,
) {
  return [];
}

void _modelSummaryCacheModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  ModelSummaryCacheModel object,
) {}

extension ModelSummaryCacheModelByIndex
    on IsarCollection<ModelSummaryCacheModel> {
  Future<ModelSummaryCacheModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  ModelSummaryCacheModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<ModelSummaryCacheModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<ModelSummaryCacheModel?> getAllByKeySync(List<String> keyValues) {
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

  Future<Id> putByKey(ModelSummaryCacheModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(ModelSummaryCacheModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<ModelSummaryCacheModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<ModelSummaryCacheModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension ModelSummaryCacheModelQueryWhereSort
    on QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QWhere> {
  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ModelSummaryCacheModelQueryWhere
    on
        QueryBuilder<
          ModelSummaryCacheModel,
          ModelSummaryCacheModel,
          QWhereClause
        > {
  QueryBuilder<
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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

extension ModelSummaryCacheModelQueryFilter
    on
        QueryBuilder<
          ModelSummaryCacheModel,
          ModelSummaryCacheModel,
          QFilterCondition
        > {
  QueryBuilder<
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
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
    ModelSummaryCacheModel,
    ModelSummaryCacheModel,
    QAfterFilterCondition
  >
  vehicleClassIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vehicleClass', value: ''),
      );
    });
  }
}

extension ModelSummaryCacheModelQueryObject
    on
        QueryBuilder<
          ModelSummaryCacheModel,
          ModelSummaryCacheModel,
          QFilterCondition
        > {}

extension ModelSummaryCacheModelQueryLinks
    on
        QueryBuilder<
          ModelSummaryCacheModel,
          ModelSummaryCacheModel,
          QFilterCondition
        > {}

extension ModelSummaryCacheModelQuerySortBy
    on QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QSortBy> {
  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByCombinedKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByCombinedKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByPowertrain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByPowertrainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByVehicleClass() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  sortByVehicleClassDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.desc);
    });
  }
}

extension ModelSummaryCacheModelQuerySortThenBy
    on
        QueryBuilder<
          ModelSummaryCacheModel,
          ModelSummaryCacheModel,
          QSortThenBy
        > {
  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByCombinedKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByCombinedKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'combinedKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByPowertrain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByPowertrainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powertrain', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByVehicleClass() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.asc);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QAfterSortBy>
  thenByVehicleClassDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.desc);
    });
  }
}

extension ModelSummaryCacheModelQueryWhereDistinct
    on QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QDistinct> {
  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QDistinct>
  distinctByCombinedKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'combinedKmPerLiter');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QDistinct>
  distinctByPowertrain({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'powertrain', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, ModelSummaryCacheModel, QDistinct>
  distinctByVehicleClass({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleClass', caseSensitive: caseSensitive);
    });
  }
}

extension ModelSummaryCacheModelQueryProperty
    on
        QueryBuilder<
          ModelSummaryCacheModel,
          ModelSummaryCacheModel,
          QQueryProperty
        > {
  QueryBuilder<ModelSummaryCacheModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, double?, QQueryOperations>
  combinedKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'combinedKmPerLiter');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, String, QQueryOperations>
  powertrainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'powertrain');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }

  QueryBuilder<ModelSummaryCacheModel, String?, QQueryOperations>
  vehicleClassProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleClass');
    });
  }
}
