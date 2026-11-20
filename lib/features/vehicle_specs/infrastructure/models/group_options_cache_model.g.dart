// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_options_cache_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetGroupOptionsCacheModelCollection on Isar {
  IsarCollection<GroupOptionsCacheModel> get groupOptionsCacheModels =>
      this.collection();
}

const GroupOptionsCacheModelSchema = CollectionSchema(
  name: r'GroupOptionsCacheModel',
  id: 3364213456746436751,
  properties: {
    r'key': PropertySchema(id: 0, name: r'key', type: IsarType.string),
    r'optionIds': PropertySchema(
      id: 1,
      name: r'optionIds',
      type: IsarType.longList,
    ),
    r'optionTexts': PropertySchema(
      id: 2,
      name: r'optionTexts',
      type: IsarType.stringList,
    ),
    r'savedAtMillis': PropertySchema(
      id: 3,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
  },

  estimateSize: _groupOptionsCacheModelEstimateSize,
  serialize: _groupOptionsCacheModelSerialize,
  deserialize: _groupOptionsCacheModelDeserialize,
  deserializeProp: _groupOptionsCacheModelDeserializeProp,
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

  getId: _groupOptionsCacheModelGetId,
  getLinks: _groupOptionsCacheModelGetLinks,
  attach: _groupOptionsCacheModelAttach,
  version: '3.4.1',
);

int _groupOptionsCacheModelEstimateSize(
  GroupOptionsCacheModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.optionIds.length * 8;
  bytesCount += 3 + object.optionTexts.length * 3;
  {
    for (var i = 0; i < object.optionTexts.length; i++) {
      final value = object.optionTexts[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _groupOptionsCacheModelSerialize(
  GroupOptionsCacheModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeLongList(offsets[1], object.optionIds);
  writer.writeStringList(offsets[2], object.optionTexts);
  writer.writeLong(offsets[3], object.savedAtMillis);
}

GroupOptionsCacheModel _groupOptionsCacheModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupOptionsCacheModel(
    id: id,
    key: reader.readString(offsets[0]),
    optionIds: reader.readLongList(offsets[1]) ?? [],
    optionTexts: reader.readStringList(offsets[2]) ?? [],
    savedAtMillis: reader.readLong(offsets[3]),
  );
  return object;
}

P _groupOptionsCacheModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _groupOptionsCacheModelGetId(GroupOptionsCacheModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groupOptionsCacheModelGetLinks(
  GroupOptionsCacheModel object,
) {
  return [];
}

void _groupOptionsCacheModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  GroupOptionsCacheModel object,
) {}

extension GroupOptionsCacheModelByIndex
    on IsarCollection<GroupOptionsCacheModel> {
  Future<GroupOptionsCacheModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  GroupOptionsCacheModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<GroupOptionsCacheModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<GroupOptionsCacheModel?> getAllByKeySync(List<String> keyValues) {
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

  Future<Id> putByKey(GroupOptionsCacheModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(GroupOptionsCacheModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<GroupOptionsCacheModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<GroupOptionsCacheModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension GroupOptionsCacheModelQueryWhereSort
    on QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QWhere> {
  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GroupOptionsCacheModelQueryWhere
    on
        QueryBuilder<
          GroupOptionsCacheModel,
          GroupOptionsCacheModel,
          QWhereClause
        > {
  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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

extension GroupOptionsCacheModelQueryFilter
    on
        QueryBuilder<
          GroupOptionsCacheModel,
          GroupOptionsCacheModel,
          QFilterCondition
        > {
  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'optionIds', value: value),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'optionIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'optionIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'optionIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionIds', length, true, length, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionIds', 0, true, 0, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionIds', 0, true, length, include);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionIds', length, include, 999999, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'optionTexts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'optionTexts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'optionTexts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'optionTexts',
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'optionTexts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'optionTexts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'optionTexts',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'optionTexts',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'optionTexts', value: ''),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'optionTexts', value: ''),
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionTexts', length, true, length, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionTexts', 0, true, 0, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionTexts', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionTexts', 0, true, length, include);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'optionTexts', length, include, 999999, true);
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
    QAfterFilterCondition
  >
  optionTextsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionTexts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
    GroupOptionsCacheModel,
    GroupOptionsCacheModel,
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
}

extension GroupOptionsCacheModelQueryObject
    on
        QueryBuilder<
          GroupOptionsCacheModel,
          GroupOptionsCacheModel,
          QFilterCondition
        > {}

extension GroupOptionsCacheModelQueryLinks
    on
        QueryBuilder<
          GroupOptionsCacheModel,
          GroupOptionsCacheModel,
          QFilterCondition
        > {}

extension GroupOptionsCacheModelQuerySortBy
    on QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QSortBy> {
  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }
}

extension GroupOptionsCacheModelQuerySortThenBy
    on
        QueryBuilder<
          GroupOptionsCacheModel,
          GroupOptionsCacheModel,
          QSortThenBy
        > {
  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }
}

extension GroupOptionsCacheModelQueryWhereDistinct
    on QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QDistinct> {
  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QDistinct>
  distinctByOptionIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'optionIds');
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QDistinct>
  distinctByOptionTexts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'optionTexts');
    });
  }

  QueryBuilder<GroupOptionsCacheModel, GroupOptionsCacheModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }
}

extension GroupOptionsCacheModelQueryProperty
    on
        QueryBuilder<
          GroupOptionsCacheModel,
          GroupOptionsCacheModel,
          QQueryProperty
        > {
  QueryBuilder<GroupOptionsCacheModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroupOptionsCacheModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<GroupOptionsCacheModel, List<int>, QQueryOperations>
  optionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'optionIds');
    });
  }

  QueryBuilder<GroupOptionsCacheModel, List<String>, QQueryOperations>
  optionTextsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'optionTexts');
    });
  }

  QueryBuilder<GroupOptionsCacheModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }
}
