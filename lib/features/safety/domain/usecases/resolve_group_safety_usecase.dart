import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/datasources/safety_cache_datasource.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_recalls_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_report_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_summary_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/repositories/recalls_repository.dart';
import 'package:cars_wheels_app/features/safety/domain/repositories/safety_ratings_repository.dart';
import 'package:cars_wheels_app/features/safety/domain/services/safety_key_builder.dart';

/// Resuelve estrellas y recalls de un grupo usando la caché antes de la red.
class ResolveGroupSafetyUseCase {
  const ResolveGroupSafetyUseCase({
    required this.cache,
    required this.ratingsRepository,
    required this.recallsRepository,
    required this.keyBuilder,
    required this.clock,
  });

  final SafetyCacheDatasource cache;
  final SafetyRatingsRepository ratingsRepository;
  final RecallsRepository recallsRepository;
  final SafetyKeyBuilder keyBuilder;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Con la red caída usa lo vencido si existe; si no, relanza la falla.
  Future<GroupSafetyReportEntity> call({
    required int year,
    required String make,
    required String model,
  }) async {
    final safety = await resolveSafety(year: year, make: make, model: model);
    final recalls = await resolveRecalls(year: year, make: make, model: model);
    return GroupSafetyReportEntity(safety: safety, recalls: recalls);
  }

  /// Solo las estrellas; permite pedirlas sin depender de los recalls.
  Future<GroupSafetyEntity?> resolveSafety({
    required int year,
    required String make,
    required String model,
  }) async {
    final key = keyBuilder.build(
      SafetyConfig.ratingsKeyKind,
      year,
      make,
      model,
    );
    final noMatchKey = keyBuilder.build(
      SafetyConfig.ratingsNoMatchKeyKind,
      year,
      make,
      model,
    );
    final cached = await cache.readRatings(key);
    if (cached != null &&
        _isFresh(cached.savedAt, SafetyConfig.ratingsTimeToLiveDays)) {
      return cached.safety;
    }
    final noMatchAt = await cache.readNoMatch(noMatchKey);
    if (noMatchAt != null &&
        _isFresh(noMatchAt, SafetyConfig.noMatchTimeToLiveDays)) {
      return null;
    }
    try {
      final safety = await ratingsRepository.getGroupSafety(year, make, model);
      if (safety == null) {
        await cache.writeNoMatch(noMatchKey, clock());
        return null;
      }
      await cache.writeRatings(
        key,
        CachedGroupSafetyEntity(safety: safety, savedAt: clock()),
      );
      return safety;
    } on AppFailure {
      if (cached != null) return cached.safety;
      if (noMatchAt != null) return null;
      rethrow;
    }
  }

  /// Solo los recalls; permite pedirlos sin depender de las estrellas.
  Future<RecallSummaryEntity?> resolveRecalls({
    required int year,
    required String make,
    required String model,
  }) async {
    final key = keyBuilder.build(
      SafetyConfig.recallsKeyKind,
      year,
      make,
      model,
    );
    final noMatchKey = keyBuilder.build(
      SafetyConfig.recallsNoMatchKeyKind,
      year,
      make,
      model,
    );
    final cached = await cache.readRecalls(key);
    if (cached != null &&
        _isFresh(cached.savedAt, SafetyConfig.recallsTimeToLiveDays)) {
      return cached.summary;
    }
    final noMatchAt = await cache.readNoMatch(noMatchKey);
    if (noMatchAt != null &&
        _isFresh(noMatchAt, SafetyConfig.noMatchTimeToLiveDays)) {
      return null;
    }
    try {
      final summary = await recallsRepository.getRecalls(year, make, model);
      if (summary == null) {
        await cache.writeNoMatch(noMatchKey, clock());
        return null;
      }
      await cache.writeRecalls(
        key,
        CachedRecallsEntity(summary: summary, savedAt: clock()),
      );
      return summary;
    } on AppFailure {
      if (cached != null) return cached.summary;
      if (noMatchAt != null) return null;
      rethrow;
    }
  }

  // Vigente mientras no cumpla los días de vigencia.
  bool _isFresh(DateTime savedAt, int days) {
    return clock().difference(savedAt) < Duration(days: days);
  }
}
