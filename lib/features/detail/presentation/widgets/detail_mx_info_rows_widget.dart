import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_info_row_widget.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Filas punteadas de México; una fila sin dato no se muestra.
class DetailMxInfoRowsWidget extends StatelessWidget {
  const DetailMxInfoRowsWidget({super.key, required this.detail});

  final VehicleDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailInfoSideMargin,
        AppSpacing.xs,
        UiConfig.detailInfoSideMargin,
        0,
      ),
      child: Column(
        children: [
          for (final (label, value) in _rows())
            DetailInfoRowWidget(label: label, value: value),
        ],
      ),
    );
  }

  List<(String, String)> _rows() {
    final cubicCentimeters = detail.displacementCubicCentimeters;
    final liters = detail.displacementLiters;
    final power = detail.powerText;
    final torque = detail.torqueText;
    final values = <(String, String?)>[
      (AppTexts.detailFuelRowLabel, detail.fuelType),
      (AppTexts.detailCylindersRowLabel, detail.cylindersLabel),
      (
        AppTexts.detailDisplacementRowLabel,
        cubicCentimeters == null || liters == null
            ? null
            : AppTexts.displacementCubicCentimetersLabel(
                cubicCentimeters,
                liters,
              ),
      ),
      (AppTexts.detailTransmissionRowLabel, detail.transmission),
      (
        AppTexts.detailPowerRowLabel,
        power == null
            ? null
            : AppTexts.peakWithRpm(power, AppTexts.horsepowerUnit),
      ),
      (
        AppTexts.detailTorqueRowLabel,
        torque == null
            ? null
            : AppTexts.peakWithRpm(torque, AppTexts.newtonMetersUnit),
      ),
      (AppTexts.detailCompressionRowLabel, detail.compressionRatioText),
    ];
    return [
      for (final (label, value) in values)
        if (value != null) (label, value),
    ];
  }
}
