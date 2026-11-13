// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_summary_cache_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetGroupSummaryCacheModelCollection on Isar {
  IsarCollection<GroupSummaryCacheModel> get groupSummaryCacheModels =>
      this.collection();
}

const GroupSummaryCacheModelSchema = CollectionSchema(
  name: r'GroupSummaryCacheModel',
  id: -808507630003371402,
  properties: {
    r'hasElectric': PropertySchema(
      id: 0,
      name: r'hasElectric',
      type: IsarType.bool,
    ),
    r'hasFuelCell': PropertySchema(
      id: 1,
      name: r'hasFuelCell',
      type: IsarType.bool,
    ),
    r'hasPluginHybrid': PropertySchema(
      id: 2,
      name: r'hasPluginHybrid',
      type: IsarType.bool,
    ),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'maxKmPerLiter': PropertySchema(
      id: 4,
      name: r'maxKmPerLiter',
      type: IsarType.double,
    ),
    r'minKmPerLiter': PropertySchema(
      id: 5,
      name: r'minKmPerLiter',
      type: IsarType.double,
    ),
    r'savedAtMillis': PropertySchema(
      id: 6,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
    r'variantCount': PropertySchema(
      id: 7,
      name: r'variantCount',
      type: IsarType.long,
    ),
    r'vehicleClass': PropertySchema(
      id: 8,
      name: r'vehicleClass',
      type: IsarType.string,
    ),
  },

  estimateSize: _groupSummaryCacheModelEstimateSize,
  serialize: _groupSummaryCacheModelSerialize,
  deserialize: _groupSummaryCacheModelDeserialize,
  deserializeProp: _groupSummaryCacheModelDeserializeProp,
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

  getId: _groupSummaryCacheModelGetId,
  getLinks: _groupSummaryCacheModelGetLinks,
  attach: _groupSummaryCacheModelAttach,
  version: '3.4.1',
);

int _groupSummaryCacheModelEstimateSize(
  GroupSummaryCacheModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.vehicleClass;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _groupSummaryCacheModelSerialize(
  GroupSummaryCacheModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hasElectric);
  writer.writeBool(offsets[1], object.hasFuelCell);
  writer.writeBool(offsets[2], object.hasPluginHybrid);
  writer.writeString(offsets[3], object.key);
  writer.writeDouble(offsets[4], object.maxKmPerLiter);
  writer.writeDouble(offsets[5], object.minKmPerLiter);
  writer.writeLong(offsets[6], object.savedAtMillis);
  writer.writeLong(offsets[7], object.variantCount);
  writer.writeString(offsets[8], object.vehicleClass);
}

GroupSummaryCacheModel _groupSummaryCacheModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupSummaryCacheModel(
    hasElectric: reader.readBool(offsets[0]),
    hasFuelCell: reader.readBool(offsets[1]),
    hasPluginHybrid: reader.readBool(offsets[2]),
    id: id,
    key: reader.readString(offsets[3]),
    maxKmPerLiter: reader.readDoubleOrNull(offsets[4]),
    minKmPerLiter: reader.readDoubleOrNull(offsets[5]),
    savedAtMillis: reader.readLong(offsets[6]),
    variantCount: reader.readLong(offsets[7]),
    vehicleClass: reader.readStringOrNull(offsets[8]),
  );
  return object;
}

P _groupSummaryCacheModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _groupSummaryCacheModelGetId(GroupSummaryCacheModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groupSummaryCacheModelGetLinks(
  GroupSummaryCacheModel object,
) {
  return [];
}

void _groupSummaryCacheModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  GroupSummaryCacheModel object,
) {}

extension GroupSummaryCacheModelByIndex
    on IsarCollection<GroupSummaryCacheModel> {
  Future<GroupSummaryCacheModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  GroupSummaryCacheModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<GroupSummaryCacheModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<GroupSummaryCacheModel?> getAllByKeySync(List<String> keyValues) {
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

  Future<Id> putByKey(GroupSummaryCacheModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(GroupSummaryCacheModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<GroupSummaryCacheModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<GroupSummaryCacheModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension GroupSummaryCacheModelQueryWhereSort
    on QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QWhere> {
  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GroupSummaryCacheModelQueryWhere
    on
        QueryBuilder<
          GroupSummaryCacheModel,
          GroupSummaryCacheModel,
          QWhereClause
        > {
  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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

extension GroupSummaryCacheModelQueryFilter
    on
        QueryBuilder<
          GroupSummaryCacheModel,
          GroupSummaryCacheModel,
          QFilterCondition
        > {
  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  hasElectricEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasElectric', value: value),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  hasFuelCellEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasFuelCell', value: value),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  hasPluginHybridEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasPluginHybrid', value: value),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  maxKmPerLiterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maxKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  maxKmPerLiterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maxKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  maxKmPerLiterEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'maxKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  maxKmPerLiterGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  maxKmPerLiterLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  maxKmPerLiterBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxKmPerLiter',
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  minKmPerLiterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'minKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  minKmPerLiterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'minKmPerLiter'),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  minKmPerLiterEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'minKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  minKmPerLiterGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'minKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  minKmPerLiterLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'minKmPerLiter',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  minKmPerLiterBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'minKmPerLiter',
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  variantCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'variantCount', value: value),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  variantCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'variantCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  variantCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'variantCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
    QAfterFilterCondition
  >
  variantCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'variantCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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
    GroupSummaryCacheModel,
    GroupSummaryCacheModel,
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

extension GroupSummaryCacheModelQueryObject
    on
        QueryBuilder<
          GroupSummaryCacheModel,
          GroupSummaryCacheModel,
          QFilterCondition
        > {}

extension GroupSummaryCacheModelQueryLinks
    on
        QueryBuilder<
          GroupSummaryCacheModel,
          GroupSummaryCacheModel,
          QFilterCondition
        > {}

extension GroupSummaryCacheModelQuerySortBy
    on QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QSortBy> {
  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByHasElectric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasElectric', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByHasElectricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasElectric', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByHasFuelCell() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFuelCell', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByHasFuelCellDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFuelCell', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByHasPluginHybrid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPluginHybrid', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByHasPluginHybridDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPluginHybrid', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByMaxKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByMaxKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByMinKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByMinKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByVariantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantCount', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByVariantCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantCount', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByVehicleClass() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  sortByVehicleClassDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.desc);
    });
  }
}

extension GroupSummaryCacheModelQuerySortThenBy
    on
        QueryBuilder<
          GroupSummaryCacheModel,
          GroupSummaryCacheModel,
          QSortThenBy
        > {
  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByHasElectric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasElectric', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByHasElectricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasElectric', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByHasFuelCell() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFuelCell', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByHasFuelCellDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFuelCell', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByHasPluginHybrid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPluginHybrid', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByHasPluginHybridDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPluginHybrid', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByMaxKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByMaxKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByMinKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minKmPerLiter', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByMinKmPerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minKmPerLiter', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByVariantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantCount', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByVariantCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantCount', Sort.desc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByVehicleClass() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.asc);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QAfterSortBy>
  thenByVehicleClassDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleClass', Sort.desc);
    });
  }
}

extension GroupSummaryCacheModelQueryWhereDistinct
    on QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct> {
  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByHasElectric() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasElectric');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByHasFuelCell() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasFuelCell');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByHasPluginHybrid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPluginHybrid');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByMaxKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxKmPerLiter');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByMinKmPerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minKmPerLiter');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByVariantCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantCount');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, GroupSummaryCacheModel, QDistinct>
  distinctByVehicleClass({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleClass', caseSensitive: caseSensitive);
    });
  }
}

extension GroupSummaryCacheModelQueryProperty
    on
        QueryBuilder<
          GroupSummaryCacheModel,
          GroupSummaryCacheModel,
          QQueryProperty
        > {
  QueryBuilder<GroupSummaryCacheModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, bool, QQueryOperations>
  hasElectricProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasElectric');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, bool, QQueryOperations>
  hasFuelCellProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasFuelCell');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, bool, QQueryOperations>
  hasPluginHybridProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPluginHybrid');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, double?, QQueryOperations>
  maxKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxKmPerLiter');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, double?, QQueryOperations>
  minKmPerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minKmPerLiter');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, int, QQueryOperations>
  variantCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantCount');
    });
  }

  QueryBuilder<GroupSummaryCacheModel, String?, QQueryOperations>
  vehicleClassProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleClass');
    });
  }
}
