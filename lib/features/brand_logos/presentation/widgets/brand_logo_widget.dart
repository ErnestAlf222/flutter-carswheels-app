import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/loaders/loaders.dart';

/// Logo de una marca; muestra un monograma si no hay logo o no carga.
class BrandLogoWidget extends StatefulWidget {
  const BrandLogoWidget({
    super.key,
    required this.brandName,
    required this.size,
  });

  final String brandName;
  final double size;

  @override
  State<BrandLogoWidget> createState() => _BrandLogoWidgetState();
}

class _BrandLogoWidgetState extends State<BrandLogoWidget> {
  @override
  void initState() {
    super.initState();
    context.read<BrandLogosCubit>().ensureLogo(widget.brandName);
  }

  @override
  void didUpdateWidget(BrandLogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brandName != widget.brandName) {
      context.read<BrandLogosCubit>().ensureLogo(widget.brandName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = context.select<BrandLogosCubit, String?>(
      (cubit) => cubit.urlFor(widget.brandName),
    );
    // Sube al volver la conexión: el logo que falló se pide de nuevo.
    final generation = context.select<BrandLogosCubit, int>((cubit) {
      final current = cubit.state;
      return current is BrandLogosLoaded ? current.generation : 0;
    });
    final monogram = _Monogram(brandName: widget.brandName, size: widget.size);
    if (url == null) return monogram;
    if (url.endsWith(LogosConfig.svgExtension)) {
      return SvgPicture(
        DiskFirstSvgLoader(
          url,
          headers: LogosConfig.requestHeaders,
          store: context.read<BrandLogosCubit>().fileStore,
          fileName: const LogoFileNamer().svgFileNameFor(url),
        ),
        key: ValueKey(generation),
        width: widget.size,
        height: widget.size,
        placeholderBuilder: (_) => monogram,
        errorBuilder: (_, _, _) => monogram,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: LogosConfig.requestHeaders,
      width: widget.size,
      height: widget.size,
      placeholder: (_, _) => monogram,
      errorWidget: (_, _, _) => monogram,
    );
  }
}

/// Inicial de la marca sobre un círculo.
class _Monogram extends StatelessWidget {
  const _Monogram({required this.brandName, required this.size});

  final String brandName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = brandName.isEmpty ? '' : brandName[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.photoPlaceholder,
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Text(
            initial,
            style: AppTextStyles.figure.copyWith(color: AppColors.mutedText),
          ),
        ),
      ),
    );
  }
}
