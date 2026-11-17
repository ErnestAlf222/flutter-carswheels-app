import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_recalls_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_summary_entity.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/recalls_cache_model.dart';

/// Convierte entre la entrada de Isar y los recalls guardados de un grupo.
class CachedRecallsMapper {
  const CachedRecallsMapper._();

  static CachedRecallsEntity toEntity(RecallsCacheModel model) {
    final json = jsonDecode(model.payload) as Map<String, dynamic>;
    final items = json[SafetyConfig.payloadRecallsKey] as List<dynamic>;
    return CachedRecallsEntity(
      summary: RecallSummaryEntity(
        recalls: [
          for (final item in items)
            _recallFromJson(item as Map<String, dynamic>),
        ],
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
    );
  }

  static RecallsCacheModel toModel(String key, CachedRecallsEntity entity) {
    return RecallsCacheModel(
      key: key,
      payload: jsonEncode({
        SafetyConfig.payloadRecallsKey: [
          for (final recall in entity.summary.recalls) _recallToJson(recall),
        ],
      }),
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }

  static RecallEntity _recallFromJson(Map<String, dynamic> json) {
    final date = json[SafetyConfig.payloadDateKey] as String?;
    return RecallEntity(
      campaignNumber: json[SafetyConfig.payloadCampaignKey] as String,
      reportDate: date == null ? null : DateTime.parse(date),
      component: json[SafetyConfig.payloadComponentKey] as String?,
      summary: json[SafetyConfig.payloadSummaryKey] as String?,
      consequence: json[SafetyConfig.payloadConsequenceKey] as String?,
      remedy: json[SafetyConfig.payloadRemedyKey] as String?,
    );
  }

  static Map<String, dynamic> _recallToJson(RecallEntity recall) {
    return {
      SafetyConfig.payloadCampaignKey: recall.campaignNumber,
      SafetyConfig.payloadDateKey: recall.reportDate?.toIso8601String(),
      SafetyConfig.payloadComponentKey: recall.component,
      SafetyConfig.payloadSummaryKey: recall.summary,
      SafetyConfig.payloadConsequenceKey: recall.consequence,
      SafetyConfig.payloadRemedyKey: recall.remedy,
    };
  }
}
