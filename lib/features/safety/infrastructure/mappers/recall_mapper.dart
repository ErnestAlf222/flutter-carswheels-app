import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/services/recall_date_parser.dart';

/// Convierte un recall de NHTSA en su entidad.
class RecallMapper {
  const RecallMapper._();

  static const RecallDateParser _dateParser = RecallDateParser();

  /// Nulo si el recall no trae número de campaña.
  static RecallEntity? toEntity(Map<String, dynamic> json) {
    final campaign = _text(json[SafetyConfig.recallCampaignKey]);
    if (campaign == null) return null;
    return RecallEntity(
      campaignNumber: campaign,
      reportDate: _dateParser.parse(_text(json[SafetyConfig.recallDateKey])),
      component: _text(json[SafetyConfig.recallComponentKey]),
      summary: _text(json[SafetyConfig.recallSummaryKey]),
      consequence: _text(json[SafetyConfig.recallConsequenceKey]),
      remedy: _text(json[SafetyConfig.recallRemedyKey]),
    );
  }

  static String? _text(Object? value) {
    final text = value is String ? value.trim() : null;
    return text == null || text.isEmpty ? null : text;
  }
}
