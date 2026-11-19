import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_figures_card_widget.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Cifras de México: km/l por ciclo, o potencia y torque si no hay consumo.
class DetailMxFiguresCardWidget extends StatelessWidget {
  const DetailMxFiguresCardWidget({super.key, required this.detail});

  final VehicleDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    // Con menos de dos cifras la tarjeta no aporta nada.
    if (cells.length < UiConfig.detailMinFigureCells) {
      return const SizedBox.shrink();
    }
    return DetailFiguresCardWidget(cells: cells);
  }

  // Solo las cifras con dato; el eléctrico y el enchufable no traen km/l.
  List<DetailFigureData> _cells() {
    final city = detail.cityKmPerLiter;
    final highway = detail.highwayKmPerLiter;
    final combined = detail.combinedKmPerLiter;
    final power = detail.powerText;
    final torque = detail.torqueText;
    final hasKmPerLiter = city != null || highway != null || combined != null;
    return [
      if (city != null)
        DetailFigureData(
          figure: AppTexts.kmPerLiterFigure(city),
          caption: AppTexts.detailCityCaption,
        ),
      if (highway != null)
        DetailFigureData(
          figure: AppTexts.kmPerLiterFigure(highway),
          caption: AppTexts.detailHighwayCaption,
        ),
      if (combined != null)
        DetailFigureData(
          figure: AppTexts.kmPerLiterFigure(combined),
          caption: AppTexts.detailCombinedCaption,
        ),
      if (!hasKmPerLiter && power != null)
        DetailFigureData(
          figure: AppTexts.peakFigure(power, AppTexts.horsepowerUnit),
          caption: AppTexts.detailPowerCaption,
        ),
      if (!hasKmPerLiter && torque != null)
        DetailFigureData(
          figure: AppTexts.peakFigure(torque, AppTexts.newtonMetersUnit),
          caption: AppTexts.detailTorqueCaption,
        ),
    ];
  }
}
