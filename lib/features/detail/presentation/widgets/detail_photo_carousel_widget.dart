import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Tarjeta deslizable con las fotos del modelo y, debajo, el crédito de la actual.
class DetailPhotoCarouselWidget extends StatelessWidget {
  const DetailPhotoCarouselWidget({
    super.key,
    required this.brandName,
    required this.heroTag,
  });

  final String brandName;

  /// Etiqueta del Hero desde la lista; nulo si no hay vuelo.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailGalleryCubit, GalleryState>(
      builder: (context, state) {
        final hasPhotos = state.photos.isNotEmpty;
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
              child: hasPhotos
                  ? _PhotoPages(
                      state: state,
                      brandName: brandName,
                      heroTag: heroTag,
                    )
                  : _FallbackBox(brandName: brandName),
            ),
            if (hasPhotos) ...[
              const SizedBox(height: UiConfig.detailCreditGap),
              Text(
                _creditText(state.photos[state.currentIndex]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ],
        );
      },
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

/// Páginas de fotos con los puntos indicadores encima.
class _PhotoPages extends StatefulWidget {
  const _PhotoPages({
    required this.state,
    required this.brandName,
    required this.heroTag,
  });

  final GalleryState state;
  final String brandName;
  final String? heroTag;

  @override
  State<_PhotoPages> createState() => _PhotoPagesState();
}

class _PhotoPagesState extends State<_PhotoPages> {
  // El controlador es un recurso: empieza en la página que indica el cubit.
  late final PageController _controller = PageController(
    initialPage: widget.state.currentIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.state.photos;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: photos.length,
          onPageChanged: (index) => _onPageChanged(context, index),
          itemBuilder: (context, index) => _PhotoPage(
            photo: photos[index],
            brandName: widget.brandName,
            heroTag: index == 0 ? widget.heroTag : null,
          ),
        ),
        if (photos.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: UiConfig.galleryDotsBottomInset,
            child: Center(
              child: _GalleryDots(
                count: photos.length,
                activeIndex: widget.state.currentIndex,
              ),
            ),
          ),
      ],
    );
  }

  // Avisa al cubit y precarga la foto siguiente para que ya esté al llegar.
  void _onPageChanged(BuildContext context, int index) {
    context.read<DetailGalleryCubit>().selectPage(index);
    final photos = widget.state.photos;
    if (index + 1 >= photos.length) return;
    context.read<PhotoPrefetcher>().prefetchLarge(context, photos[index + 1]);
  }
}

/// Una foto: la pequeña difuminada de fondo y la nítida encima.
class _PhotoPage extends StatelessWidget {
  const _PhotoPage({
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
    final smallUrl = const ThumbnailUrlBuilder().forUrl(
      photo.thumbnailUrl,
      PhotosConfig.listThumbnailWidthPixels,
    );
    final sharp = CachedNetworkImage(
      imageUrl: photo.thumbnailUrl,
      httpHeaders: PhotosConfig.requestHeaders,
      fit: BoxFit.contain,
      fadeInDuration: fade,
      fadeOutDuration: fade,
      placeholder: (context, _) => CachedNetworkImage(
        imageUrl: smallUrl,
        httpHeaders: PhotosConfig.requestHeaders,
        fit: BoxFit.contain,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, _) => const SizedBox.shrink(),
        errorWidget: (context, _, _) => const SizedBox.shrink(),
      ),
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
            imageUrl: smallUrl,
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

/// Pastilla con un punto por foto; el activo va resaltado.
class _GalleryDots extends StatelessWidget {
  const _GalleryDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final fade = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.fadeDurationMilliseconds,
          );
    return Container(
      padding: const EdgeInsets.all(UiConfig.galleryDotsPadding),
      decoration: BoxDecoration(
        color: AppColors.shadow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: UiConfig.galleryDotSpacing,
        children: [
          for (final index in Iterable<int>.generate(count))
            Semantics(
              label: AppTexts.photoPositionSemanticLabel(index + 1, count),
              selected: index == activeIndex,
              child: AnimatedContainer(
                duration: fade,
                width: UiConfig.galleryDotSize,
                height: UiConfig.galleryDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == activeIndex
                      ? AppColors.galleryDotActive
                      : AppColors.galleryDotInactive,
                ),
              ),
            ),
        ],
      ),
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
