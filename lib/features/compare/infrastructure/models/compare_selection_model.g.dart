// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compare_selection_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetCompareSelectionModelCollection on Isar {
  IsarCollection<CompareSelectionModel> get compareSelectionModels =>
      this.collection();
}

const CompareSelectionModelSchema = CollectionSchema(
  name: r'CompareSelectionModel',
  id: 3609633997282414059,
  properties: {
    r'key': PropertySchema(id: 0, name: r'key', type: IsarType.string),
    r'payload': PropertySchema(id: 1, name: r'payload', type: IsarType.string),
    r'savedAtMillis': PropertySchema(
      id: 2,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
  },

  estimateSize: _compareSelectionModelEstimateSize,
  serialize: _compareSelectionModelSerialize,
  deserialize: _compareSelectionModelDeserialize,
  deserializeProp: _compareSelectionModelDeserializeProp,
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

  getId: _compareSelectionModelGetId,
  getLinks: _compareSelectionModelGetLinks,
  attach: _compareSelectionModelAttach,
  version: '3.4.1',
);

int _compareSelectionModelEstimateSize(
  CompareSelectionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  return bytesCount;
}

void _compareSelectionModelSerialize(
  CompareSelectionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeString(offsets[1], object.payload);
  writer.writeLong(offsets[2], object.savedAtMillis);
}

CompareSelectionModel _compareSelectionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CompareSelectionModel(
    id: id,
    key: reader.readString(offsets[0]),
    payload: reader.readString(offsets[1]),
    savedAtMillis: reader.readLong(offsets[2]),
  );
  return object;
}

P _compareSelectionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _compareSelectionModelGetId(CompareSelectionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _compareSelectionModelGetLinks(
  CompareSelectionModel object,
) {
  return [];
}

void _compareSelectionModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  CompareSelectionModel object,
) {}

extension CompareSelectionModelByIndex
    on IsarCollection<CompareSelectionModel> {
  Future<CompareSelectionModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  CompareSelectionModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<CompareSelectionModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<CompareSelectionModel?> getAllByKeySync(List<String> keyValues) {
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

  Future<Id> putByKey(CompareSelectionModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(CompareSelectionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<CompareSelectionModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<CompareSelectionModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension CompareSelectionModelQueryWhereSort
    on QueryBuilder<CompareSelectionModel, CompareSelectionModel, QWhere> {
  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CompareSelectionModelQueryWhere
    on
        QueryBuilder<
          CompareSelectionModel,
          CompareSelectionModel,
          QWhereClause
        > {
  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
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

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
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

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
  keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterWhereClause>
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

extension CompareSelectionModelQueryFilter
    on
        QueryBuilder<
          CompareSelectionModel,
          CompareSelectionModel,
          QFilterCondition
        > {
  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payload',
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
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payload',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: ''),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
    QAfterFilterCondition
  >
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payload', value: ''),
      );
    });
  }

  QueryBuilder<
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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
    CompareSelectionModel,
    CompareSelectionModel,
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

extension CompareSelectionModelQueryObject
    on
        QueryBuilder<
          CompareSelectionModel,
          CompareSelectionModel,
          QFilterCondition
        > {}

extension CompareSelectionModelQueryLinks
    on
        QueryBuilder<
          CompareSelectionModel,
          CompareSelectionModel,
          QFilterCondition
        > {}

extension CompareSelectionModelQuerySortBy
    on QueryBuilder<CompareSelectionModel, CompareSelectionModel, QSortBy> {
  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }
}

extension CompareSelectionModelQuerySortThenBy
    on QueryBuilder<CompareSelectionModel, CompareSelectionModel, QSortThenBy> {
  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }
}

extension CompareSelectionModelQueryWhereDistinct
    on QueryBuilder<CompareSelectionModel, CompareSelectionModel, QDistinct> {
  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QDistinct>
  distinctByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CompareSelectionModel, CompareSelectionModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }
}

extension CompareSelectionModelQueryProperty
    on
        QueryBuilder<
          CompareSelectionModel,
          CompareSelectionModel,
          QQueryProperty
        > {
  QueryBuilder<CompareSelectionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CompareSelectionModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<CompareSelectionModel, String, QQueryOperations>
  payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<CompareSelectionModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }
}
