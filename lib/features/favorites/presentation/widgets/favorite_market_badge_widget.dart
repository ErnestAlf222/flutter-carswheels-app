import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Insignia discreta con la bandera del mercado y el año, sobre la foto.
class FavoriteMarketBadgeWidget extends StatelessWidget {
  const FavoriteMarketBadgeWidget({
    super.key,
    required this.marketCode,
    required this.year,
  });

  final String marketCode;
  final int year;

  @override
  Widget build(BuildContext context) {
    final flag = marketCode == MarketConfig.mexicoCode
        ? MarketConfig.mexicoFlag
        : MarketConfig.unitedStatesFlag;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.circleButtonOnPhoto,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FavoritesConfig.marketBadgeHorizontalPadding,
          vertical: FavoritesConfig.marketBadgeVerticalPadding,
        ),
        child: Text(
          AppTexts.favoriteMarketYearLabel(flag, year),
          maxLines: 1,
          style: AppTextStyles.caption.copyWith(color: AppColors.onDark),
        ),
      ),
    );
  }
}
