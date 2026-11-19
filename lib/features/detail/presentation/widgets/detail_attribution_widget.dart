import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Nota pequeña con la fuente de los datos de México (CC BY 4.0).
class DetailAttributionWidget extends StatelessWidget {
  const DetailAttributionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailInfoSideMargin,
        UiConfig.detailAttributionTopMargin,
        UiConfig.detailInfoSideMargin,
        0,
      ),
      child: SolidBackgroundWidget(
        child: Text(
          AppTexts.conueeAttribution,
          textAlign: TextAlign.center,
          style: AppTextStyles.attributionNote,
        ),
      ),
    );
  }
}
