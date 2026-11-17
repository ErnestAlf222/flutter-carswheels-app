import 'package:equatable/equatable.dart';

/// Un recall de NHTSA; la fecha es nula si su formato no es inequívoco.
class RecallEntity extends Equatable {
  const RecallEntity({
    required this.campaignNumber,
    this.reportDate,
    this.component,
    this.summary,
    this.consequence,
    this.remedy,
  });

  final String campaignNumber;
  final DateTime? reportDate;
  final String? component;
  final String? summary;
  final String? consequence;
  final String? remedy;

  @override
  List<Object?> get props => [
    campaignNumber,
    reportDate,
    component,
    summary,
    consequence,
    remedy,
  ];
}
