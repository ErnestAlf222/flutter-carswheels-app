import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/photos/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/photos/presentation/widgets/local_first_image_widget.dart';

/// Foto de un modelo; sin foto muestra el recuadro de respaldo.
class ModelPhotoWidget extends StatelessWidget {
  const ModelPhotoWidget({
    super.key,
    required this.brand,
    required this.model,
    required this.year,
    required this.borderRadius,
    this.borderRadiusGeometry,
    this.width,
    this.height,
    this.heroTag,
    this.showNoPhotoBadge = true,
    this.thumbnailUrlBuilder = const ThumbnailUrlBuilder(),
  });

  final String brand;

  /// Nombre del modelo tal como lo entrega FuelEconomy.
  final String model;
  final int year;

  /// Ancho y alto del recuadro; sin ellos ocupa el espacio que le den.
  final double? width;
  final double? height;
  final double borderRadius;

  /// Si se da, reemplaza al radio uniforme (p. ej. solo esquinas superiores).
  final BorderRadius? borderRadiusGeometry;

  /// Etiqueta del Hero hacia Detalle; sin ella la foto no vuela.
  final String? heroTag;

  /// Falso en el listado: sin foto queda solo el logo, sin la cámara tachada.
  final bool showNoPhotoBadge;
  final ThumbnailUrlBuilder thumbnailUrlBuilder;

  @override
  Widget build(BuildContext context) {
    final key = context.read<PhotosCubit>().keyFor(
      PhotoRequest(brand: brand, model: model, year: year),
    );
    return BlocSelector<PhotosCubit, PhotosState, PhotoSlot?>(
      selector: (state) => state.slots[key],
      builder: (context, slot) => _frame(context, slot),
    );
  }

  Widget _frame(BuildContext context, PhotoSlot? slot) {
    final radius = borderRadiusGeometry ?? BorderRadius.circular(borderRadius);
    final tag = heroTag;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pixelsWide = width ?? constraints.maxWidth;
            final memCacheWidth = pixelsWide.isFinite
                ? (pixelsWide * MediaQuery.devicePixelRatioOf(context)).ceil()
                : null;
            return slot is PhotoFound
                ? _withHero(tag, _content(slot.photo, memCacheWidth))
                : slot is PhotoMissing || slot is PhotoFailed
                ? _NoPhotoBox(brand: brand, showBadge: showNoPhotoBadge)
                : _LoadingBox(brand: brand);
          },
        ),
      ),
    );
  }

  Widget _content(PhotoEntity photo, int? memCacheWidth) => _PhotoContent(
    brand: brand,
    localPath: photo.localPath,
    thumbnailUrl: thumbnailUrlBuilder.forUrl(
      photo.thumbnailUrl,
      PhotosConfig.listThumbnailWidthPixels,
    ),
    memCacheWidth: memCacheWidth,
    showNoPhotoBadge: showNoPhotoBadge,
  );

  // Envuelve la foto en un Hero solo si hay etiqueta.
  Widget _withHero(String? tag, Widget child) => tag == null
      ? child
      : Hero(
          tag: tag,
          flightShuttleBuilder: PhotoHeroShuttle.builder,
          child: child,
        );
}

/// Imagen con fundido de entrada.
class _PhotoContent extends StatelessWidget {
  const _PhotoContent({
    required this.brand,
    required this.thumbnailUrl,
    required this.localPath,
    required this.memCacheWidth,
    required this.showNoPhotoBadge,
  });

  final String brand;
  final String thumbnailUrl;
  final String? localPath;
  final int? memCacheWidth;
  final bool showNoPhotoBadge;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final fade = media.disableAnimations ? Duration.zero : AppMotion.medium;
    // Con el archivo local no hace falta la red; si falla, se usa la URL.
    return LocalFirstImageWidget(
      localPath: localPath,
      fit: BoxFit.cover,
      cacheWidth: memCacheWidth,
      networkBuilder: (context) => CachedNetworkImage(
        imageUrl: thumbnailUrl,
        httpHeaders: PhotosConfig.requestHeaders,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        memCacheWidth: memCacheWidth,
        fadeInDuration: fade,
        fadeOutDuration: fade,
        placeholder: (context, _) => _LoadingBox(brand: brand),
        errorWidget: (context, _, _) =>
            _NoPhotoBox(brand: brand, showBadge: showNoPhotoBadge),
      ),
    );
  }
}

/// Logo de la marca o, sin logo, un icono de auto.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final hasLogo = context.select<BrandLogosCubit, bool>(
      (cubit) => cubit.urlFor(brand) != null,
    );
    return hasLogo
        ? BrandLogoWidget(
            brandName: brand,
            size: UiConfig.brandFallbackLogoSize,
          )
        : const Icon(
            Symbols.directions_car,
            size: UiConfig.iconSize,
            color: AppColors.mutedText,
          );
  }
}

/// Cargando: el logo tenue con un pulso suave sobre el fondo de color.
class _LoadingBox extends StatelessWidget {
  const _LoadingBox({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final mark = Opacity(
      opacity: UiConfig.rowPhotoLoadingLogoOpacity,
      child: _BrandMark(brand: brand),
    );
    return ColoredBox(
      color: AppColors.photoPlaceholder,
      child: Center(
        child: MediaQuery.of(context).disableAnimations
            ? mark
            : Pulse(
                infinite: true,
                to: UiConfig.skeletonPulseScale,
                duration: const Duration(
                  milliseconds: AnimationConfig.skeletonPulseMilliseconds,
                ),
                child: mark,
              ),
      ),
    );
  }
}

/// Sin foto: el logo completo y, si se pide, una insignia abajo a la derecha.
class _NoPhotoBox extends StatelessWidget {
  const _NoPhotoBox({required this.brand, required this.showBadge});

  final String brand;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: AppColors.photoPlaceholder,
          child: Center(child: _BrandMark(brand: brand)),
        ),
        if (showBadge)
          const Align(alignment: Alignment.bottomRight, child: _NoPhotoBadge()),
      ],
    );
  }
}

/// Insignia pequeña que explica que este modelo no tiene foto.
class _NoPhotoBadge extends StatelessWidget {
  const _NoPhotoBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppTexts.noPhotoSemanticLabel,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.no_photography,
          size: UiConfig.rowNoPhotoBadgeSize,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}
