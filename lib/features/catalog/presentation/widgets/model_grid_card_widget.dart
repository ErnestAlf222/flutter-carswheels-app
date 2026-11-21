import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_grid_metrics.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Tarjeta vertical de un grupo: foto, nombre, clase y consumo.
class ModelGridCardWidget extends StatelessWidget {
  const ModelGridCardWidget({
    super.key,
    required this.group,
    required this.brand,
    required this.year,
    required this.index,
    this.onTap,
    this.animateEntry = true,
    this.showBrandLabel = false,
    this.footerAction,
    this.leadingAction,
    this.photoBadge,
    this.photoAspectRatio = ModelGridConfig.photoAspectRatio,
  });

  final ModelGroupEntity group;
  final String brand;
  final int year;

  /// Posición del modelo en la lista; define el retardo de entrada.
  final int index;

  /// Al tocar la tarjeta; sin ella la tarjeta no responde.
  final VoidCallback? onTap;

  /// Falso cuando la lista no usa la entrada en cascada (Favoritos).
  final bool animateEntry;

  /// Muestra la marca en mayúsculas sobre el nombre (resultados de búsqueda).
  final bool showBrandLabel;

  /// Acción opcional al pie, a la derecha; la capa app la provee (selector de Comparar).
  final Widget? footerAction;

  /// Acción opcional en la esquina superior izquierda de la foto (el corazón).
  final Widget? leadingAction;

  /// Insignia opcional en la esquina inferior izquierda de la foto.
  final Widget? photoBadge;

  /// Proporción (ancho / alto) de la foto; el mosaico de Favoritos la cambia por tarjeta.
  final double photoAspectRatio;

  @override
  Widget build(BuildContext context) {
    final name = group.name;
    final summaryKey = context.read<SummariesCubit>().keyFor(brand, name, year);
    final heroTag = context.read<PhotosCubit>().keyFor(
      PhotoRequest(brand: brand, model: name, year: year),
    );
    final scaler = MediaQuery.textScalerOf(context);
    final action = footerAction;
    final card = BlocSelector<SummariesCubit, SummariesState, String?>(
      selector: (state) => state.consumptionLabelFor(summaryKey),
      builder: (context, consumption) => Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label: AppTexts.modelSummarySemanticLabel(name, consumption),
            excludeSemantics: true,
            child: _Tappable(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PhotoArea(
                    brand: brand,
                    name: name,
                    year: year,
                    heroTag: heroTag,
                    photoBadge: photoBadge,
                    aspectRatio: photoAspectRatio,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        ModelGridConfig.textHorizontalPadding,
                        ModelGridConfig.textTopPadding,
                        ModelGridConfig.textHorizontalPadding,
                        ModelGridConfig.textBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filas de alto fijo: todas las tarjetas miden lo mismo.
                          if (showBrandLabel)
                            SizedBox(
                              height: ModelGridMetrics.brandLabelHeight(scaler),
                              width: double.infinity,
                              child: Text(
                                brand.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.brandOverline,
                              ),
                            ),
                          SizedBox(
                            height: ModelGridMetrics.nameHeight(scaler),
                            width: double.infinity,
                            child: Text(
                              name,
                              maxLines: ModelGridConfig.nameMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.modelName,
                            ),
                          ),
                          const SizedBox(height: ModelGridConfig.classTopGap),
                          SizedBox(
                            height: ModelGridMetrics.classHeight(scaler),
                            width: double.infinity,
                            child: ModelClassTextWidget(
                              brand: brand,
                              groupName: name,
                              year: year,
                            ),
                          ),
                          const SizedBox(
                            height: ModelGridConfig.consumptionTopGap,
                          ),
                          SizedBox(
                            height: ModelGridMetrics.consumptionHeight(scaler),
                            width: double.infinity,
                            child: ModelConsumptionBlockWidget(
                              brand: brand,
                              groupName: name,
                              year: year,
                            ),
                          ),
                          // Espacio reservado: la acción se dibuja encima de la tarjeta.
                          if (action != null)
                            const SizedBox(
                              height: ModelGridMetrics.actionRowTotalHeight,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Las acciones van sobre la tarjeta y no dentro de su semántica
          // excluida: lectores de pantalla y toques las alcanzan por separado.
          if (leadingAction case final lead?)
            Positioned(
              top: ModelGridConfig.leadingActionTopInset,
              left: ModelGridConfig.leadingActionLeftInset,
              child: lead,
            ),
          if (action != null)
            Positioned(
              right: ModelGridConfig.textHorizontalPadding,
              bottom: ModelGridConfig.textBottomPadding,
              height: ModelGridConfig.actionRowHeight,
              child: Align(alignment: Alignment.centerRight, child: action),
            ),
        ],
      ),
    );
    // Cada tarjeta se pinta en su propia capa: el scroll no la repinta.
    final isolated = RepaintBoundary(child: card);
    if (!animateEntry) return isolated;
    return StaggeredEntryWidget(index: index, child: isolated);
  }
}

/// Foto a todo el ancho, pegada arriba, con la insignia de motorización.
class _PhotoArea extends StatelessWidget {
  const _PhotoArea({
    required this.brand,
    required this.name,
    required this.year,
    required this.heroTag,
    required this.aspectRatio,
    this.photoBadge,
  });

  final String brand;
  final String name;
  final int year;
  final String heroTag;
  final double aspectRatio;
  final Widget? photoBadge;

  @override
  Widget build(BuildContext context) {
    const topCorners = BorderRadius.vertical(
      top: Radius.circular(AppRadii.card),
    );
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModelPhotoWidget(
            brand: brand,
            model: name,
            year: year,
            borderRadius: AppRadii.card,
            borderRadiusGeometry: topCorners,
            heroTag: heroTag,
            showNoPhotoBadge: false,
          ),
          Positioned(
            top: ModelGridConfig.badgeInset,
            right: ModelGridConfig.badgeInset,
            child: EngineBadgeWidget(brand: brand, groupName: name, year: year),
          ),
          if (photoBadge case final badge?)
            Positioned(
              left: ModelGridConfig.badgeInset,
              bottom: ModelGridConfig.badgeInset,
              child: badge,
            ),
        ],
      ),
    );
  }
}

/// Fondo de la tarjeta; si hay onTap, toda la tarjeta responde al toque.
class _Tappable extends StatelessWidget {
  const _Tappable({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.card);
    final callback = onTap;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.outline, width: UiConfig.cardBorderWidth),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: callback == null
          ? child
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: callback,
                borderRadius: radius,
                child: child,
              ),
            ),
    );
  }
}
