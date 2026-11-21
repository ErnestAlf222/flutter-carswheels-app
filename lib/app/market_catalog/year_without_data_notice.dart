import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Año elegido por la persona en el catálogo y la marca activa no tiene registros.
bool isCatalogYearGap(CatalogState previous, CatalogState current) =>
    current is CatalogLoaded &&
    current.droppedBrand != null &&
    (previous is! CatalogLoaded ||
        previous.droppedBrand != current.droppedBrand ||
        previous.year != current.year);

/// La búsqueda perdió su marca de alcance por un cambio de año.
bool isSearchYearGap(SearchState previous, SearchState current) =>
    current.droppedBrand != null &&
    previous.droppedBrand != current.droppedBrand;

/// Aviso pequeño y no bloqueante: la marca activa no tiene registros ese año.
void showYearWithoutDataNotice(
  ScaffoldMessengerState messenger, {
  required String brand,
  required int year,
}) {
  final safeBottom = MediaQuery.paddingOf(messenger.context).bottom;
  messenger
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        elevation: 0,
        duration: const Duration(
          milliseconds: MarketConfig.yearNoticeDurationMilliseconds,
        ),
        margin: EdgeInsets.only(
          left: MarketConfig.noticeSideMargin,
          right: MarketConfig.noticeSideMargin,
          bottom:
              NavConfig.footprint + safeBottom + MarketConfig.noticeBottomGap,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MarketConfig.noticeHorizontalPadding,
          vertical: MarketConfig.noticeVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MarketConfig.noticeRadius),
        ),
        content: Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Symbols.info,
                size: MarketConfig.yearNoticeIconSize,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: MarketConfig.noticeGap),
            Expanded(
              child: Text(
                AppTexts.yearWithoutDataNotice(brand, year),
                style: AppTextStyles.caption.copyWith(color: AppColors.onDark),
              ),
            ),
          ],
        ),
      ),
    );
}
