import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
                  : _EmptyOrLoading(
                      isLoading: state.isLoading,
                      brandName: brandName,
                    ),
            ),
            if (hasPhotos) ...[
              const SizedBox(height: UiConfig.detailCreditGap),
              Text(
                _creditText(state.photos[state.currentIndex]),
                maxLines: UiConfig.photoCreditMaxLines,
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

  // Autor y licencia; la cápsula de la tarjeta avisa si es de referencia.
  static String _creditText(PhotoEntity photo) {
    final author = photo.authorName.trim().isEmpty
        ? AppTexts.authorMissingLabel
        : photo.authorName;
    return AppTexts.photoCreditLabel(author, photo.licenseName);
  }
}

/// Tarjeta sin fotos: cargando o, si ya terminó, el aviso de sin foto.
class _EmptyOrLoading extends StatelessWidget {
  const _EmptyOrLoading({required this.isLoading, required this.brandName});

  final bool isLoading;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const PhotoPlaceholderWidget(kind: PhotoPlaceholderKind.loading);
    }
    return PhotoPlaceholderWidget(
      kind: PhotoPlaceholderKind.empty,
      logo: BrandLogoWidget(
        brandName: brandName,
        size: UiConfig.photoEmptyLogoSize,
      ),
    );
  }
}

/// Páginas de fotos con la cápsula y los puntos indicadores encima.
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
    final current = photos[widget.state.currentIndex];
    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          button: true,
          label: AppTexts.expandPhotoSemanticLabel,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openViewer(context),
            child: PageView.builder(
              controller: _controller,
              itemCount: photos.length,
              onPageChanged: (index) => _onPageChanged(context, index),
              itemBuilder: (context, index) => _PhotoPage(
                photo: photos[index],
                brandName: widget.brandName,
                heroTag: index == 0 ? widget.heroTag : null,
              ),
            ),
          ),
        ),
        if (current.isReference)
          const Positioned(
            top: UiConfig.photoChipInset,
            left: UiConfig.photoChipInset,
            child: _ReferenceChip(),
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

  // Abre el visor y, si devuelve un índice, mueve el carrusel a esa foto.
  Future<void> _openViewer(BuildContext context) async {
    final cubit = context.read<DetailGalleryCubit>();
    final result = await context.push<int>(
      RoutesConfig.photoViewer,
      extra: PhotoViewerArgsEntity(
        widget.state.photos,
        initialIndex: widget.state.currentIndex,
      ),
    );
    if (result == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) _controller.jumpToPage(result);
    });
    cubit.selectPage(result);
  }

  // Avisa al cubit y precarga la foto siguiente para que ya esté al llegar.
  void _onPageChanged(BuildContext context, int index) {
    context.read<DetailGalleryCubit>().selectPage(index);
    final photos = widget.state.photos;
    if (index + 1 >= photos.length) return;
    context.read<PhotoPrefetcher>().prefetchLarge(context, photos[index + 1]);
  }
}

/// Una foto: llena la tarjeta o va completa sobre su propio fondo difuminado.
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
    final mode = const PhotoFitResolver().resolve(photo.aspectRatio);
    final fit = mode == PhotoFitMode.cover ? BoxFit.cover : BoxFit.contain;
    const loading = PhotoPlaceholderWidget(kind: PhotoPlaceholderKind.loading);
    final sharp = CachedNetworkImage(
      imageUrl: photo.thumbnailUrl,
      httpHeaders: PhotosConfig.requestHeaders,
      fit: fit,
      alignment: Alignment.center,
      fadeInDuration: fade,
      fadeOutDuration: fade,
      placeholder: (context, _) => CachedNetworkImage(
        imageUrl: smallUrl,
        httpHeaders: PhotosConfig.requestHeaders,
        fit: fit,
        alignment: Alignment.center,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, _) => loading,
        errorWidget: (context, _, _) => loading,
      ),
      errorWidget: (context, _, _) =>
          _EmptyOrLoading(isLoading: false, brandName: brandName),
    );
    final tag = heroTag;
    final image = tag == null
        ? sharp
        : Hero(
            tag: tag,
            flightShuttleBuilder: PhotoHeroShuttle.builder,
            child: sharp,
          );
    if (mode == PhotoFitMode.cover) return image;
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
        image,
      ],
    );
  }
}

/// Cápsula que avisa que la foto no es del año pedido.
class _ReferenceChip extends StatelessWidget {
  const _ReferenceChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.photoChipBackground,
        borderRadius: BorderRadius.circular(UiConfig.photoChipRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.photoChipHorizontalPadding,
          vertical: UiConfig.photoChipVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs / 2,
          children: [
            const Icon(
              Symbols.info,
              size: UiConfig.photoChipIconSize,
              color: AppColors.onGradient,
            ),
            Text(
              AppTexts.referencePhotoLabel,
              style: AppTextStyles.photoChipLabel,
            ),
          ],
        ),
      ),
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
        color: AppColors.galleryDotsBackground,
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
