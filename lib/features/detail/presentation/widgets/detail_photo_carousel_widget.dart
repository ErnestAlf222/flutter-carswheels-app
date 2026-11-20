import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Foto a todo el ancho con las fotos del modelo deslizables.
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
      builder: (context, state) => Container(
        height: UiConfig.detailPhotoHeight,
        width: double.infinity,
        // La tinta se ve en las fotos "contain" y en las de respaldo.
        color: AppColors.ink,
        child: state.photos.isNotEmpty
            ? _PhotoPages(state: state, brandName: brandName, heroTag: heroTag)
            : _EmptyOrLoading(isLoading: state.isLoading, brandName: brandName),
      ),
    );
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
    initialPage: CircularIndex.initialPage(
      widget.state.currentIndex,
      widget.state.photos.length,
    ),
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
              itemCount: CircularIndex.pageCount(photos.length),
              onPageChanged: (page) => _onPageChanged(context, page),
              itemBuilder: (context, page) {
                final index = CircularIndex.wrap(page, photos.length);
                return _PhotoPage(
                  photo: photos[index],
                  brandName: widget.brandName,
                  heroTag: index == 0 ? widget.heroTag : null,
                );
              },
            ),
          ),
        ),
        // Superposición oscura hacia tinta para leer los textos sobre la foto.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.photoOverlay),
            ),
          ),
        ),
        if (current.isReference)
          const Positioned(
            top: UiConfig.detailPhotoChipTop,
            left: UiConfig.detailPhotoChipLeft,
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
      if (_controller.hasClients) {
        _controller.jumpToPage(
          CircularIndex.initialPage(result, widget.state.photos.length),
        );
      }
    });
    cubit.selectPage(result);
  }

  // Avisa al cubit con el índice real y precarga la foto siguiente (con vuelta).
  void _onPageChanged(BuildContext context, int page) {
    final photos = widget.state.photos;
    final index = CircularIndex.wrap(page, photos.length);
    context.read<DetailGalleryCubit>().selectPage(index);
    if (photos.length < 2) return;
    final next = CircularIndex.next(index, photos.length);
    context.read<PhotoPrefetcher>().prefetchLarge(context, photos[next]);
  }
}

/// Una foto: llena el recuadro o va completa sobre el degradado.
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
    final network = CachedNetworkImage(
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
    // Abierto desde Favoritos, la foto guardada en el teléfono va antes que la red.
    final sharp = LocalFirstImageWidget(
      localPath: photo.localPath,
      fit: fit,
      networkBuilder: (context) => network,
    );
    final tag = heroTag;
    final image = tag == null
        ? sharp
        : Hero(
            tag: tag,
            flightShuttleBuilder: PhotoHeroShuttle.builder,
            child: sharp,
          );
    return image;
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
              color: AppColors.onDark,
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
