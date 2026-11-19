// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_commons_logo_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetCachedCommonsLogoModelCollection on Isar {
  IsarCollection<CachedCommonsLogoModel> get cachedCommonsLogoModels =>
      this.collection();
}

const CachedCommonsLogoModelSchema = CollectionSchema(
  name: r'CachedCommonsLogoModel',
  id: -4189620257449761613,
  properties: {
    r'authorName': PropertySchema(
      id: 0,
      name: r'authorName',
      type: IsarType.string,
    ),
    r'found': PropertySchema(id: 1, name: r'found', type: IsarType.bool),
    r'key': PropertySchema(id: 2, name: r'key', type: IsarType.string),
    r'licenseName': PropertySchema(
      id: 3,
      name: r'licenseName',
      type: IsarType.string,
    ),
    r'savedAtMillis': PropertySchema(
      id: 4,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
    r'sourceUrl': PropertySchema(
      id: 5,
      name: r'sourceUrl',
      type: IsarType.string,
    ),
    r'url': PropertySchema(id: 6, name: r'url', type: IsarType.string),
  },

  estimateSize: _cachedCommonsLogoModelEstimateSize,
  serialize: _cachedCommonsLogoModelSerialize,
  deserialize: _cachedCommonsLogoModelDeserialize,
  deserializeProp: _cachedCommonsLogoModelDeserializeProp,
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

  getId: _cachedCommonsLogoModelGetId,
  getLinks: _cachedCommonsLogoModelGetLinks,
  attach: _cachedCommonsLogoModelAttach,
  version: '3.4.1',
);

int _cachedCommonsLogoModelEstimateSize(
  CachedCommonsLogoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorName.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.licenseName.length * 3;
  bytesCount += 3 + object.sourceUrl.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _cachedCommonsLogoModelSerialize(
  CachedCommonsLogoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authorName);
  writer.writeBool(offsets[1], object.found);
  writer.writeString(offsets[2], object.key);
  writer.writeString(offsets[3], object.licenseName);
  writer.writeLong(offsets[4], object.savedAtMillis);
  writer.writeString(offsets[5], object.sourceUrl);
  writer.writeString(offsets[6], object.url);
}

CachedCommonsLogoModel _cachedCommonsLogoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedCommonsLogoModel(
    authorName: reader.readString(offsets[0]),
    found: reader.readBool(offsets[1]),
    id: id,
    key: reader.readString(offsets[2]),
    licenseName: reader.readString(offsets[3]),
    savedAtMillis: reader.readLong(offsets[4]),
    sourceUrl: reader.readString(offsets[5]),
    url: reader.readString(offsets[6]),
  );
  return object;
}

P _cachedCommonsLogoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedCommonsLogoModelGetId(CachedCommonsLogoModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedCommonsLogoModelGetLinks(
  CachedCommonsLogoModel object,
) {
  return [];
}

void _cachedCommonsLogoModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  CachedCommonsLogoModel object,
) {}

extension CachedCommonsLogoModelByIndex
    on IsarCollection<CachedCommonsLogoModel> {
  Future<CachedCommonsLogoModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  CachedCommonsLogoModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<CachedCommonsLogoModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<CachedCommonsLogoModel?> getAllByKeySync(List<String> keyValues) {
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

  Future<Id> putByKey(CachedCommonsLogoModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(CachedCommonsLogoModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<CachedCommonsLogoModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<CachedCommonsLogoModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension CachedCommonsLogoModelQueryWhereSort
    on QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QWhere> {
  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedCommonsLogoModelQueryWhere
    on
        QueryBuilder<
          CachedCommonsLogoModel,
          CachedCommonsLogoModel,
          QWhereClause
        > {
  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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

extension CachedCommonsLogoModelQueryFilter
    on
        QueryBuilder<
          CachedCommonsLogoModel,
          CachedCommonsLogoModel,
          QFilterCondition
        > {
  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'authorName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'authorName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'authorName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'authorName',
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'authorName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'authorName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'authorName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'authorName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'authorName', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  authorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'authorName', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  foundEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'found', value: value),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'licenseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'licenseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'licenseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'licenseName',
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'licenseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'licenseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'licenseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'licenseName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'licenseName', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  licenseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'licenseName', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceUrl',
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  sourceUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
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
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCommonsLogoModel,
    CachedCommonsLogoModel,
    QAfterFilterCondition
  >
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension CachedCommonsLogoModelQueryObject
    on
        QueryBuilder<
          CachedCommonsLogoModel,
          CachedCommonsLogoModel,
          QFilterCondition
        > {}

extension CachedCommonsLogoModelQueryLinks
    on
        QueryBuilder<
          CachedCommonsLogoModel,
          CachedCommonsLogoModel,
          QFilterCondition
        > {}

extension CachedCommonsLogoModelQuerySortBy
    on QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QSortBy> {
  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByLicenseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByLicenseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension CachedCommonsLogoModelQuerySortThenBy
    on
        QueryBuilder<
          CachedCommonsLogoModel,
          CachedCommonsLogoModel,
          QSortThenBy
        > {
  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByLicenseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByLicenseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QAfterSortBy>
  thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension CachedCommonsLogoModelQueryWhereDistinct
    on QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct> {
  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctByAuthorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctByFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'found');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctByLicenseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licenseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctBySourceUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCommonsLogoModel, CachedCommonsLogoModel, QDistinct>
  distinctByUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension CachedCommonsLogoModelQueryProperty
    on
        QueryBuilder<
          CachedCommonsLogoModel,
          CachedCommonsLogoModel,
          QQueryProperty
        > {
  QueryBuilder<CachedCommonsLogoModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, String, QQueryOperations>
  authorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorName');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, bool, QQueryOperations> foundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'found');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, String, QQueryOperations>
  licenseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licenseName');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, String, QQueryOperations>
  sourceUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrl');
    });
  }

  QueryBuilder<CachedCommonsLogoModel, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
