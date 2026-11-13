// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_photo_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetCachedPhotoModelCollection on Isar {
  IsarCollection<CachedPhotoModel> get cachedPhotoModels => this.collection();
}

const CachedPhotoModelSchema = CollectionSchema(
  name: r'CachedPhotoModel',
  id: -3815901699830975315,
  properties: {
    r'aspectRatio': PropertySchema(
      id: 0,
      name: r'aspectRatio',
      type: IsarType.double,
    ),
    r'authorName': PropertySchema(
      id: 1,
      name: r'authorName',
      type: IsarType.string,
    ),
    r'found': PropertySchema(id: 2, name: r'found', type: IsarType.bool),
    r'isReference': PropertySchema(
      id: 3,
      name: r'isReference',
      type: IsarType.bool,
    ),
    r'key': PropertySchema(id: 4, name: r'key', type: IsarType.string),
    r'licenseName': PropertySchema(
      id: 5,
      name: r'licenseName',
      type: IsarType.string,
    ),
    r'savedAtMillis': PropertySchema(
      id: 6,
      name: r'savedAtMillis',
      type: IsarType.long,
    ),
    r'sourceUrl': PropertySchema(
      id: 7,
      name: r'sourceUrl',
      type: IsarType.string,
    ),
    r'thumbnailUrl': PropertySchema(
      id: 8,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
  },

  estimateSize: _cachedPhotoModelEstimateSize,
  serialize: _cachedPhotoModelSerialize,
  deserialize: _cachedPhotoModelDeserialize,
  deserializeProp: _cachedPhotoModelDeserializeProp,
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

  getId: _cachedPhotoModelGetId,
  getLinks: _cachedPhotoModelGetLinks,
  attach: _cachedPhotoModelAttach,
  version: '3.4.1',
);

int _cachedPhotoModelEstimateSize(
  CachedPhotoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorName.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.licenseName.length * 3;
  bytesCount += 3 + object.sourceUrl.length * 3;
  bytesCount += 3 + object.thumbnailUrl.length * 3;
  return bytesCount;
}

void _cachedPhotoModelSerialize(
  CachedPhotoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.aspectRatio);
  writer.writeString(offsets[1], object.authorName);
  writer.writeBool(offsets[2], object.found);
  writer.writeBool(offsets[3], object.isReference);
  writer.writeString(offsets[4], object.key);
  writer.writeString(offsets[5], object.licenseName);
  writer.writeLong(offsets[6], object.savedAtMillis);
  writer.writeString(offsets[7], object.sourceUrl);
  writer.writeString(offsets[8], object.thumbnailUrl);
}

CachedPhotoModel _cachedPhotoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedPhotoModel(
    aspectRatio: reader.readDoubleOrNull(offsets[0]),
    authorName: reader.readString(offsets[1]),
    found: reader.readBool(offsets[2]),
    id: id,
    isReference: reader.readBool(offsets[3]),
    key: reader.readString(offsets[4]),
    licenseName: reader.readString(offsets[5]),
    savedAtMillis: reader.readLong(offsets[6]),
    sourceUrl: reader.readString(offsets[7]),
    thumbnailUrl: reader.readString(offsets[8]),
  );
  return object;
}

P _cachedPhotoModelDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedPhotoModelGetId(CachedPhotoModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedPhotoModelGetLinks(CachedPhotoModel object) {
  return [];
}

void _cachedPhotoModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  CachedPhotoModel object,
) {}

extension CachedPhotoModelByIndex on IsarCollection<CachedPhotoModel> {
  Future<CachedPhotoModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  CachedPhotoModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<CachedPhotoModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<CachedPhotoModel?> getAllByKeySync(List<String> keyValues) {
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

  Future<Id> putByKey(CachedPhotoModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(CachedPhotoModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<CachedPhotoModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<CachedPhotoModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension CachedPhotoModelQueryWhereSort
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QWhere> {
  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedPhotoModelQueryWhere
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QWhereClause> {
  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause>
  keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterWhereClause>
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

extension CachedPhotoModelQueryFilter
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QFilterCondition> {
  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  aspectRatioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aspectRatio'),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  aspectRatioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aspectRatio'),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  aspectRatioEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aspectRatio',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  aspectRatioGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aspectRatio',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  aspectRatioLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aspectRatio',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  aspectRatioBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aspectRatio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  authorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'authorName', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  authorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'authorName', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  foundEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'found', value: value),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  isReferenceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isReference', value: value),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  licenseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'licenseName', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  licenseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'licenseName', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  savedAtMillisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedAtMillis', value: value),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
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

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  sourceUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  sourceUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thumbnailUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thumbnailUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterFilterCondition>
  thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thumbnailUrl', value: ''),
      );
    });
  }
}

extension CachedPhotoModelQueryObject
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QFilterCondition> {}

extension CachedPhotoModelQueryLinks
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QFilterCondition> {}

extension CachedPhotoModelQuerySortBy
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QSortBy> {
  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByAspectRatio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aspectRatio', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByAspectRatioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aspectRatio', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy> sortByFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByIsReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReference', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByIsReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReference', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByLicenseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByLicenseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }
}

extension CachedPhotoModelQuerySortThenBy
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QSortThenBy> {
  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByAspectRatio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aspectRatio', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByAspectRatioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aspectRatio', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy> thenByFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'found', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByIsReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReference', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByIsReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReference', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByLicenseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByLicenseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseName', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenBySavedAtMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMillis', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QAfterSortBy>
  thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }
}

extension CachedPhotoModelQueryWhereDistinct
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct> {
  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctByAspectRatio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aspectRatio');
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctByAuthorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctByFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'found');
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctByIsReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReference');
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctByLicenseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licenseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctBySavedAtMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMillis');
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctBySourceUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedPhotoModel, CachedPhotoModel, QDistinct>
  distinctByThumbnailUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }
}

extension CachedPhotoModelQueryProperty
    on QueryBuilder<CachedPhotoModel, CachedPhotoModel, QQueryProperty> {
  QueryBuilder<CachedPhotoModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedPhotoModel, double?, QQueryOperations>
  aspectRatioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aspectRatio');
    });
  }

  QueryBuilder<CachedPhotoModel, String, QQueryOperations>
  authorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorName');
    });
  }

  QueryBuilder<CachedPhotoModel, bool, QQueryOperations> foundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'found');
    });
  }

  QueryBuilder<CachedPhotoModel, bool, QQueryOperations> isReferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReference');
    });
  }

  QueryBuilder<CachedPhotoModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<CachedPhotoModel, String, QQueryOperations>
  licenseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licenseName');
    });
  }

  QueryBuilder<CachedPhotoModel, int, QQueryOperations>
  savedAtMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMillis');
    });
  }

  QueryBuilder<CachedPhotoModel, String, QQueryOperations> sourceUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrl');
    });
  }

  QueryBuilder<CachedPhotoModel, String, QQueryOperations>
  thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }
}
