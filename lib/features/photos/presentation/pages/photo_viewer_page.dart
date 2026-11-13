import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/presentation/cubits/cubits.dart';

/// Visor a pantalla completa: acerca con pellizco y desliza entre fotos.
class PhotoViewerPage extends StatelessWidget {
  const PhotoViewerPage({super.key, required this.args});

  final PhotoViewerArgsEntity args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PhotoViewerCubit>(
      create: (_) => PhotoViewerCubit(
        initialIndex: args.initialIndex,
        photoCount: args.photos.length,
      ),
      child: _ViewerBody(args: args),
    );
  }
}

/// Fotos, botón de cerrar y pie con crédito y puntos.
class _ViewerBody extends StatefulWidget {
  const _ViewerBody({required this.args});

  final PhotoViewerArgsEntity args;

  @override
  State<_ViewerBody> createState() => _ViewerBodyState();
}

class _ViewerBodyState extends State<_ViewerBody> {
  // El controlador es un recurso: empieza en la foto que se pidió.
  late final PageController _controller = PageController(
    initialPage: widget.args.initialIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.args.photos;
    return BlocBuilder<PhotoViewerCubit, PhotoViewerState>(
      builder: (context, state) {
        // El gesto de atrás también devuelve la foto actual.
        return PopScope<Object?>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.pop(state.currentIndex);
          },
          child: Scaffold(
            backgroundColor: AppColors.photoViewerBackground,
            body: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: photos.length,
                  onPageChanged: context.read<PhotoViewerCubit>().selectPage,
                  itemBuilder: (context, index) =>
                      _ZoomablePhoto(photo: photos[index]),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      child: _CloseButton(
                        onTap: () => context.pop(state.currentIndex),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _Footer(
                    photo: photos[state.currentIndex],
                    count: photos.length,
                    activeIndex: state.currentIndex,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Foto con zoom; la miniatura pequeña se ve mientras baja la grande.
class _ZoomablePhoto extends StatelessWidget {
  const _ZoomablePhoto({required this.photo});

  final PhotoEntity photo;

  @override
  Widget build(BuildContext context) {
    final smallUrl = const ThumbnailUrlBuilder().forUrl(
      photo.thumbnailUrl,
      PhotosConfig.listThumbnailWidthPixels,
    );
    const loading = PhotoPlaceholderWidget(kind: PhotoPlaceholderKind.loading);
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: UiConfig.photoViewerMaxScale,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: photo.thumbnailUrl,
          httpHeaders: PhotosConfig.requestHeaders,
          fit: BoxFit.contain,
          placeholder: (context, _) => CachedNetworkImage(
            imageUrl: smallUrl,
            httpHeaders: PhotosConfig.requestHeaders,
            fit: BoxFit.contain,
            placeholder: (context, _) => loading,
            errorWidget: (context, _, _) => loading,
          ),
          errorWidget: (context, _, _) =>
              const PhotoPlaceholderWidget(kind: PhotoPlaceholderKind.empty),
        ),
      ),
    );
  }
}

/// Botón circular para cerrar el visor.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.photoViewerCloseLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: UiConfig.photoViewerCloseSize,
          height: UiConfig.photoViewerCloseSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.photoChipBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.close,
            size: UiConfig.iconSize,
            color: AppColors.onGradient,
          ),
        ),
      ),
    );
  }
}

/// Pie oscuro con el crédito de la foto actual y los puntos.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.photo,
    required this.count,
    required this.activeIndex,
  });

  final PhotoEntity photo;
  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final author = photo.authorName.trim().isEmpty
        ? AppTexts.authorMissingLabel
        : photo.authorName;
    return Container(
      width: double.infinity,
      color: AppColors.photoChipBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.s,
            AppSpacing.m,
            UiConfig.photoViewerDotBottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              if (photo.isReference)
                Text(
                  AppTexts.referencePhotoLabel,
                  style: AppTextStyles.photoChipLabel,
                ),
              Text(
                AppTexts.photoCreditLabel(author, photo.licenseName),
                textAlign: TextAlign.center,
                style: AppTextStyles.photoViewerCredit,
              ),
              if (count > 1) _Dots(count: count, activeIndex: activeIndex),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un punto por foto; el activo va resaltado.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: UiConfig.galleryDotSpacing,
      children: [
        for (final index in Iterable<int>.generate(count))
          Semantics(
            label: AppTexts.photoPositionSemanticLabel(index + 1, count),
            selected: index == activeIndex,
            child: Container(
              width: UiConfig.galleryDotSize,
              height: UiConfig.galleryDotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == activeIndex
                    ? AppColors.onGradient
                    : AppColors.galleryDotInactive,
              ),
            ),
          ),
      ],
    );
  }
}
