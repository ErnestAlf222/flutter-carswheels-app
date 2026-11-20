import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// El cambio de mercado lo hizo la persona: ya se había restaurado el guardado.
///
/// La restauración al arrancar emite desde un estado sin restaurar y no cuenta.
bool isUserMarketChange(MarketState previous, MarketState current) =>
    previous.isRestored && previous.market != current.market;

/// Aviso breve al cambiar de mercado desde la píldora: bandera, qué cambió y qué se ve.
///
/// Es un SnackBar flotante de Material con estilo propio (tinta y amarillo, sin
/// brillo), colocado sobre la barra de navegación flotante. En Comparar la línea
/// secundaria dice que se ve la comparación de ese mercado.
void showMarketChangedNotice(
  ScaffoldMessengerState messenger, {
  required Market market,
  required int year,
  required bool onCompare,
}) {
  final name = AppTexts.marketLabelOf(market.code);
  final context = messenger.context;
  final safeBottom = MediaQuery.paddingOf(context).bottom;
  // Solo el último cambio cuenta si la persona alterna varias veces seguidas.
  messenger
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        elevation: 0,
        duration: const Duration(
          milliseconds: MarketConfig.noticeDurationMilliseconds,
        ),
        margin: EdgeInsets.only(
          left: MarketConfig.noticeSideMargin,
          right: MarketConfig.noticeSideMargin,
          bottom:
              NavConfig.footprint + safeBottom + MarketConfig.noticeBottomGap,
        ),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MarketConfig.noticeRadius),
        ),
        content: _MarketNoticeContent(
          flag: market.flag,
          title: AppTexts.marketChangedTitle(name),
          body: onCompare
              ? AppTexts.marketChangedCompareBody(name)
              : AppTexts.marketChangedBody(name, year),
        ),
      ),
    );
}

/// Bandera en un aro amarillo y dos líneas de texto.
class _MarketNoticeContent extends StatelessWidget {
  const _MarketNoticeContent({
    required this.flag,
    required this.title,
    required this.body,
  });

  final String flag;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketConfig.noticeHorizontalPadding,
        vertical: MarketConfig.noticeVerticalPadding,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: MarketConfig.flagRingWidth,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs / 2),
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: MarketConfig.noticeFlagSize),
                ),
              ),
            ),
          ),
          const SizedBox(width: MarketConfig.noticeGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.onDark,
                  ),
                ),
                Text(
                  body,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedOnDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
