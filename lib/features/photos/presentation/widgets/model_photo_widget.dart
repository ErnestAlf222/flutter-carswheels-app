import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/photos/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/presentation/cubits/cubits.dart';

/// Foto de un modelo; sin foto muestra el recuadro de respaldo.
class ModelPhotoWidget extends StatelessWidget {
  const ModelPhotoWidget({
    super.key,
    required this.brand,
    required this.model,
    required this.year,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.heroTag,
    this.thumbnailUrlBuilder = const ThumbnailUrlBuilder(),
  });

  final String brand;

  /// Nombre del modelo tal como lo entrega FuelEconomy.
  final String model;
  final int year;

  /// Ancho y alto del recuadro.
  final double width;
  final double height;
  final double borderRadius;

  /// Etiqueta del Hero hacia Detalle; sin ella la foto no vuela.
  final String? heroTag;
  final ThumbnailUrlBuilder thumbnailUrlBuilder;

  @override
  Widget build(BuildContext context) {
    final key = context.read<PhotosCubit>().keyFor(
      PhotoRequest(brand: brand, model: model, year: year),
    );
    return BlocSelector<PhotosCubit, PhotosState, PhotoSlot?>(
      selector: (state) => state.slots[key],
      builder: (context, slot) {
        final radius = BorderRadius.circular(borderRadius);
        final found = slot;
        final tag = heroTag;
        return SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: radius,
            child: found is PhotoFound
                ? _withHero(
                    tag,
                    _PhotoContent(
                      photo: found.photo,
                      width: width,
                      brand: brand,
                      thumbnailUrl: thumbnailUrlBuilder.forUrl(
                        found.photo.thumbnailUrl,
                        PhotosConfig.listThumbnailWidthPixels,
                      ),
                    ),
                  )
                : slot is PhotoMissing || slot is PhotoFailed
                ? _NoPhotoBox(brand: brand)
                : _LoadingBox(brand: brand),
          ),
        );
      },
    );
  }
}

// Envuelve la foto en un Hero solo si hay etiqueta.
Widget _withHero(String? tag, Widget child) => tag == null
    ? child
    : Hero(
        tag: tag,
        flightShuttleBuilder: PhotoHeroShuttle.builder,
        child: child,
      );

/// Imagen con fundido y, si es de referencia, su insignia.
class _PhotoContent extends StatelessWidget {
  const _PhotoContent({
    required this.photo,
    required this.width,
    required this.brand,
    required this.thumbnailUrl,
  });

  final PhotoEntity photo;
  final double width;
  final String brand;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final fade = media.disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.fadeDurationMilliseconds,
          );
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          httpHeaders: PhotosConfig.requestHeaders,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          memCacheWidth: (width * media.devicePixelRatio).ceil(),
          fadeInDuration: fade,
          fadeOutDuration: fade,
          placeholder: (context, _) => _LoadingBox(brand: brand),
          errorWidget: (context, _, _) => _NoPhotoBox(brand: brand),
        ),
        if (photo.isReference)
          const Align(
            alignment: Alignment.bottomRight,
            child: _ReferenceBadge(),
          ),
      ],
    );
  }
}

/// Insignia que avisa que la foto no es del año pedido.
class _ReferenceBadge extends StatelessWidget {
  const _ReferenceBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppTexts.referencePhotoLabel,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.info,
          size: UiConfig.referenceBadgeSize,
          color: AppColors.tintText,
        ),
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
            color: AppColors.tintText,
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
      color: AppColors.tint,
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

/// Sin foto: el logo completo y una insignia en la esquina inferior derecha.
class _NoPhotoBox extends StatelessWidget {
  const _NoPhotoBox({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: AppColors.tint,
          child: Center(child: _BrandMark(brand: brand)),
        ),
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
          color: AppColors.card,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Symbols.no_photography,
          size: UiConfig.rowNoPhotoBadgeSize,
          color: AppColors.tintText,
        ),
      ),
    );
  }
}
