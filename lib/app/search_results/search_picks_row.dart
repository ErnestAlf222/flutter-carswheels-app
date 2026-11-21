import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/search_results/search_results_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Fila horizontal de sugerencias "para ti": tarjetas compactas con foto, marca y modelo.
///
/// Sin corazón ni acciones; tocar una abre Detalle. Las fotos usan las mismas
/// cachés que el resto de las tarjetas.
Widget buildSearchPicksRow(
  BuildContext context,
  List<SearchResultEntity> picks,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen, {
  SearchResultActionBuilder? actionBuilder,
}) {
  final scaler = MediaQuery.textScalerOf(context);
  const photoHeight =
      SearchConfig.picksCardWidth / SearchConfig.picksPhotoAspectRatio;
  // Alto fijo: foto, marca y hasta dos líneas de modelo, según la escala del texto.
  final textHeight =
      scaler.scale(
        AppTextStyles.brandOverline.fontSize! *
            AppTextStyles.brandOverline.height!,
      ) +
      2 *
          scaler.scale(
            AppTextStyles.modelName.fontSize! * AppTextStyles.modelName.height!,
          );
  // Con acción (botón "Comparar") la tarjeta crece lo que mide el botón.
  final actionHeight = actionBuilder == null
      ? 0.0
      : AppSpacing.xs + CompareConfig.pickerButtonHeight;
  final height = photoHeight + AppSpacing.xs * 2 + textHeight + actionHeight;
  return SearchCardsScope(
    resetKey: resetKey,
    child: SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.pageHorizontalPadding,
        ),
        itemCount: picks.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: SearchConfig.picksCardGap),
        itemBuilder: (context, index) => _PickCard(
          key: ValueKey((resetKey, picks[index])),
          result: picks[index],
          onTap: () => onOpen(picks[index]),
          action: actionBuilder?.call(context, picks[index]),
        ),
      ),
    ),
  );
}

/// Tarjeta compacta: pide su foto al mostrarse.
class _PickCard extends StatefulWidget {
  const _PickCard({
    super.key,
    required this.result,
    required this.onTap,
    this.action,
  });

  final SearchResultEntity result;
  final VoidCallback onTap;
  final Widget? action;

  @override
  State<_PickCard> createState() => _PickCardState();
}

class _PickCardState extends State<_PickCard> {
  @override
  void initState() {
    super.initState();
    // El cubit cambia de estado después de construir, no durante.
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPhoto());
  }

  void _requestPhoto() {
    if (!mounted) return;
    final result = widget.result;
    final name = result.groupName;
    final photos = context.read<PhotosCubit>();
    if (name == null || photos.isClosed) return;
    photos.requestPhotos([
      PhotoRequest(brand: result.brand, model: name, year: result.year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final name = result.groupName ?? result.brand;
    final radius = BorderRadius.circular(SearchConfig.picksRadius);
    final body = Semantics(
      button: true,
      label: AppTexts.searchPickSemanticLabel(result.brand, name),
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: SearchConfig.picksPhotoAspectRatio,
              child: ModelPhotoWidget(
                brand: result.brand,
                model: name,
                year: result.year,
                borderRadius: SearchConfig.picksRadius,
                heroTag: context.read<PhotosCubit>().keyFor(
                  PhotoRequest(
                    brand: result.brand,
                    model: name,
                    year: result.year,
                  ),
                ),
                showNoPhotoBadge: false,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              result.brand.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.brandOverline,
            ),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.modelName,
            ),
          ],
        ),
      ),
    );
    final action = widget.action;
    return SizedBox(
      width: SearchConfig.picksCardWidth,
      // El botón queda al pie y alineado entre tarjetas de nombre corto o largo.
      child: action == null
          ? body
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: body),
                const SizedBox(height: AppSpacing.xs),
                action,
              ],
            ),
    );
  }
}
