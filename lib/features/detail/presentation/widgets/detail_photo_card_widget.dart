import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Tarjeta con la foto del modelo y, debajo, su línea de crédito.
class DetailPhotoCardWidget extends StatelessWidget {
  const DetailPhotoCardWidget({
    super.key,
    required this.photo,
    required this.brandName,
    required this.heroTag,
  });

  final PhotoEntity? photo;
  final String brandName;

  /// Etiqueta del Hero desde la lista; nulo si no hay vuelo.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final current = photo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: UiConfig.detailPhotoHeight,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.detailPhotoCard),
            boxShadow: AppShadows.soft,
          ),
          child: current == null
              ? _FallbackBox(brandName: brandName)
              : _PhotoStack(
                  photo: current,
                  brandName: brandName,
                  heroTag: heroTag,
                ),
        ),
        if (current != null) ...[
          const SizedBox(height: UiConfig.detailCreditGap),
          Text(
            _creditText(current),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }

  // Autor y licencia; la foto de referencia lo indica antes.
  static String _creditText(PhotoEntity photo) {
    final author = photo.authorName.trim().isEmpty
        ? AppTexts.authorMissingLabel
        : photo.authorName;
    final credit = AppTexts.photoCreditLabel(author, photo.licenseName);
    if (!photo.isReference) return credit;
    return '${AppTexts.referencePhotoLabel}${AppTexts.creditSeparator}$credit';
  }
}

/// Foto nítida sobre la misma foto difuminada.
class _PhotoStack extends StatelessWidget {
  const _PhotoStack({
    required this.photo,
    required this.brandName,
    required this.heroTag,
  });

  final PhotoEntity photo;
  final String brandName;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final fade = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.fadeDurationMilliseconds,
          );
    final sharp = CachedNetworkImage(
      imageUrl: photo.thumbnailUrl,
      httpHeaders: PhotosConfig.requestHeaders,
      fit: BoxFit.contain,
      fadeInDuration: fade,
      fadeOutDuration: fade,
      placeholder: (context, _) => const SizedBox.shrink(),
      errorWidget: (context, _, _) => _FallbackBox(brandName: brandName),
    );
    final tag = heroTag;
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: UiConfig.detailPhotoBlurSigma,
            sigmaY: UiConfig.detailPhotoBlurSigma,
          ),
          child: CachedNetworkImage(
            imageUrl: photo.thumbnailUrl,
            httpHeaders: PhotosConfig.requestHeaders,
            fit: BoxFit.cover,
            fadeInDuration: fade,
            fadeOutDuration: fade,
            placeholder: (context, _) =>
                const ColoredBox(color: AppColors.tint),
            errorWidget: (context, _, _) =>
                const ColoredBox(color: AppColors.tint),
          ),
        ),
        if (tag == null)
          sharp
        else
          Hero(
            tag: tag,
            flightShuttleBuilder: PhotoHeroShuttle.builder,
            child: sharp,
          ),
      ],
    );
  }
}

/// Recuadro de respaldo con el logo de la marca.
class _FallbackBox extends StatelessWidget {
  const _FallbackBox({required this.brandName});

  final String brandName;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.tint,
      child: BrandLogoWidget(
        brandName: brandName,
        size: UiConfig.brandFallbackLogoSize,
      ),
    );
  }
}
