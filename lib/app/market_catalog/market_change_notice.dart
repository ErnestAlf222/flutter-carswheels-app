import 'package:flutter/material.dart';

import 'package:cars_wheels_app/app/market_catalog/market_change_celebration.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// El cambio de mercado lo hizo la persona: ya se había restaurado el guardado.
///
/// La restauración al arrancar emite desde un estado sin restaurar y no cuenta.
bool isUserMarketChange(MarketState previous, MarketState current) =>
    previous.isRestored && previous.market != current.market;

// Celebraciones en curso: solo la última cuenta si se alterna varias veces seguidas.
final List<OverlayEntry> _activeCelebrations = [];

/// Aviso al cambiar de mercado desde la píldora: qué cambió y qué se ve.
///
/// Con movimiento normal es una celebración (bandera ondeando) sobre el
/// contenido, que no bloquea la recarga. Con `disableAnimations`, o sin capa
/// donde dibujar, queda el SnackBar estático. En Comparar la línea secundaria
/// dice que se ve la comparación de ese mercado.
void showMarketChangedNotice(
  ScaffoldMessengerState messenger, {
  required Market market,
  required int year,
  required bool onCompare,
  OverlayState? overlay,
}) {
  final name = AppTexts.marketLabelOf(market.code);
  final title = AppTexts.marketChangedTitle(name);
  final body = onCompare
      ? AppTexts.marketChangedCompareBody(name)
      : AppTexts.marketChangedBody(name, year);
  _dismissCelebrations();
  final reduced = MediaQuery.of(messenger.context).disableAnimations;
  if (overlay == null || reduced) {
    _showStaticNotice(messenger, flag: market.flag, title: title, body: body);
    return;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => MarketChangeCelebration(
      market: market,
      title: title,
      body: body,
      onDone: () {
        // Ya retirada (terminó y se omitió a la vez): nada que hacer.
        if (!entry.mounted) return;
        _activeCelebrations.remove(entry);
        entry.remove();
        entry.dispose();
      },
    ),
  );
  _activeCelebrations.add(entry);
  overlay.insert(entry);
}

void _dismissCelebrations() {
  for (final entry in [..._activeCelebrations]) {
    if (entry.mounted) entry.remove();
    entry.dispose();
  }
  _activeCelebrations.clear();
}

// Versión estática: SnackBar flotante de tinta sobre la barra de navegación.
void _showStaticNotice(
  ScaffoldMessengerState messenger, {
  required String flag,
  required String title,
  required String body,
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
        content: _MarketNoticeContent(flag: flag, title: title, body: body),
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
                  width: MarketConfig.noticeFlagRingWidth,
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
