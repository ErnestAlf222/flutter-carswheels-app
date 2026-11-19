// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_preference_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetMarketPreferenceModelCollection on Isar {
  IsarCollection<MarketPreferenceModel> get marketPreferenceModels =>
      this.collection();
}

const MarketPreferenceModelSchema = CollectionSchema(
  name: r'MarketPreferenceModel',
  id: 4090537358778217007,
  properties: {
    r'marketCode': PropertySchema(
      id: 0,
      name: r'marketCode',
      type: IsarType.string,
    ),
  },

  estimateSize: _marketPreferenceModelEstimateSize,
  serialize: _marketPreferenceModelSerialize,
  deserialize: _marketPreferenceModelDeserialize,
  deserializeProp: _marketPreferenceModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _marketPreferenceModelGetId,
  getLinks: _marketPreferenceModelGetLinks,
  attach: _marketPreferenceModelAttach,
  version: '3.4.1',
);

int _marketPreferenceModelEstimateSize(
  MarketPreferenceModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.marketCode.length * 3;
  return bytesCount;
}

void _marketPreferenceModelSerialize(
  MarketPreferenceModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.marketCode);
}

MarketPreferenceModel _marketPreferenceModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MarketPreferenceModel(
    id: id,
    marketCode: reader.readString(offsets[0]),
  );
  return object;
}

P _marketPreferenceModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _marketPreferenceModelGetId(MarketPreferenceModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _marketPreferenceModelGetLinks(
  MarketPreferenceModel object,
) {
  return [];
}

void _marketPreferenceModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  MarketPreferenceModel object,
) {}

extension MarketPreferenceModelQueryWhereSort
    on QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QWhere> {
  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MarketPreferenceModelQueryWhere
    on
        QueryBuilder<
          MarketPreferenceModel,
          MarketPreferenceModel,
          QWhereClause
        > {
  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterWhereClause>
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

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterWhereClause>
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
}

extension MarketPreferenceModelQueryFilter
    on
        QueryBuilder<
          MarketPreferenceModel,
          MarketPreferenceModel,
          QFilterCondition
        > {
  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
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
    MarketPreferenceModel,
    MarketPreferenceModel,
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
    MarketPreferenceModel,
    MarketPreferenceModel,
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
    MarketPreferenceModel,
    MarketPreferenceModel,
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
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'marketCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'marketCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'marketCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'marketCode',
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
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'marketCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'marketCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'marketCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'marketCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'marketCode', value: ''),
      );
    });
  }

  QueryBuilder<
    MarketPreferenceModel,
    MarketPreferenceModel,
    QAfterFilterCondition
  >
  marketCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'marketCode', value: ''),
      );
    });
  }
}

extension MarketPreferenceModelQueryObject
    on
        QueryBuilder<
          MarketPreferenceModel,
          MarketPreferenceModel,
          QFilterCondition
        > {}

extension MarketPreferenceModelQueryLinks
    on
        QueryBuilder<
          MarketPreferenceModel,
          MarketPreferenceModel,
          QFilterCondition
        > {}

extension MarketPreferenceModelQuerySortBy
    on QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QSortBy> {
  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterSortBy>
  sortByMarketCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCode', Sort.asc);
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterSortBy>
  sortByMarketCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCode', Sort.desc);
    });
  }
}

extension MarketPreferenceModelQuerySortThenBy
    on QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QSortThenBy> {
  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterSortBy>
  thenByMarketCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCode', Sort.asc);
    });
  }

  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QAfterSortBy>
  thenByMarketCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketCode', Sort.desc);
    });
  }
}

extension MarketPreferenceModelQueryWhereDistinct
    on QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QDistinct> {
  QueryBuilder<MarketPreferenceModel, MarketPreferenceModel, QDistinct>
  distinctByMarketCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marketCode', caseSensitive: caseSensitive);
    });
  }
}

extension MarketPreferenceModelQueryProperty
    on
        QueryBuilder<
          MarketPreferenceModel,
          MarketPreferenceModel,
          QQueryProperty
        > {
  QueryBuilder<MarketPreferenceModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MarketPreferenceModel, String, QQueryOperations>
  marketCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marketCode');
    });
  }
}
