import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/loaders/loaders.dart';

/// Logo de una marca; muestra un monograma si no hay logo o no carga.
class BrandLogoWidget extends StatelessWidget {
  const BrandLogoWidget({
    super.key,
    required this.brandName,
    required this.size,
  });

  final String brandName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = context.select<BrandLogosCubit, String?>(
      (cubit) => cubit.urlFor(brandName),
    );
    final monogram = _Monogram(brandName: brandName, size: size);
    if (url == null) return monogram;
    if (url.endsWith(LogosConfig.svgExtension)) {
      return SvgPicture(
        SanitizedSvgNetworkLoader(url, headers: LogosConfig.requestHeaders),
        width: size,
        height: size,
        placeholderBuilder: (_) => monogram,
        errorBuilder: (_, _, _) => monogram,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: LogosConfig.requestHeaders,
      width: size,
      height: size,
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
        color: AppColors.tint,
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Text(
            initial,
            style: AppTextStyles.figure.copyWith(color: AppColors.tintText),
          ),
        ),
      ),
    );
  }
}
