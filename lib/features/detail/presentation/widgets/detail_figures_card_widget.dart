import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Lo que muestra una celda; isLabel indica texto de motor en vez de cifra.
class DetailFigureData {
  const DetailFigureData({
    required this.figure,
    required this.caption,
    this.isLabel = false,
    this.isLoading = false,
    this.extra,
    this.semanticLabel,
  });

  final String figure;
  final String caption;
  final bool isLabel;

  /// Cifra aún en camino: se dibuja un esqueleto en su lugar.
  final bool isLoading;

  /// Contenido bajo la cifra, como las estrellas.
  final Widget? extra;

  /// Etiqueta de accesibilidad propia; sin ella se usan cifra y título.
  final String? semanticLabel;
}

/// Tarjeta de cifras en fila, separadas por líneas verticales.
class DetailFiguresCardWidget extends StatelessWidget {
  const DetailFiguresCardWidget({super.key, required this.cells});

  final List<DetailFigureData> cells;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = cells
        .map((cell) => cell.semanticLabel ?? '${cell.figure}, ${cell.caption}')
        .join(AppTexts.semanticListSeparator);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailStatsSideMargin,
        AppSpacing.s,
        UiConfig.detailStatsSideMargin,
        0,
      ),
      child: Semantics(
        container: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: UiConfig.detailStatsVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.soft,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int index = 0; index < cells.length; index++) ...[
                  if (index > 0) const _StatDivider(),
                  Expanded(child: _StatCell(data: cells[index])),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Una celda: la cifra y su etiqueta debajo.
class _StatCell extends StatelessWidget {
  const _StatCell({required this.data});

  final DetailFigureData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.isLoading)
            const SkeletonBarWidget(
              width: UiConfig.safetySkeletonFigureWidth,
              height: UiConfig.safetySkeletonFigureHeight,
            )
          else
            Text(
              data.figure,
              maxLines: data.isLabel ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: data.isLabel
                  ? AppTextStyles.cardTitle
                  : AppTextStyles.statFigure,
            ),
          ?data.extra,
          Text(
            data.caption,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(height: 1.3),
          ),
        ],
      ),
    );
  }
}

/// Línea vertical entre celdas.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: UiConfig.detailStatDividerWidth,
      child: ColoredBox(color: AppColors.line),
    );
  }
}
