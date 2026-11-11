import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/brand_tile_widget.dart';

/// Fila con flechas y una ventana circular de marcas.
class BrandCarouselWidget extends StatelessWidget {
  const BrandCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state is! CatalogLoaded) return const SizedBox.shrink();
        final brandCount = state.brands.length;
        final visibleCount = math.min(
          CarouselConfig.visibleBrandCount,
          brandCount,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArrowButton(
              icon: Symbols.chevron_left,
              label: AppTexts.previousBrandsLabel,
              onPressed: cubit.showPreviousBrands,
            ),
            ...List.generate(visibleCount, (position) {
              final brandIndex = (state.windowStart + position) % brandCount;
              return Expanded(
                key: ValueKey(brandIndex),
                child: AnimatedEntryWidget(
                  index: position,
                  child: Center(
                    child: BrandTileWidget(
                      brandName: state.brands[brandIndex].name,
                      selected: brandIndex == state.selectedIndex,
                      onTap: () => cubit.selectBrand(brandIndex),
                    ),
                  ),
                ),
              );
            }),
            _ArrowButton(
              icon: Symbols.chevron_right,
              label: AppTexts.nextBrandsLabel,
              onPressed: cubit.showNextBrands,
            ),
          ],
        );
      },
    );
  }
}

/// Botón circular de flecha.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: CarouselConfig.arrowButtonSize,
          height: CarouselConfig.arrowButtonSize,
          decoration: const BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Icon(icon, size: UiConfig.iconSize, color: AppColors.ink),
        ),
      ),
    );
  }
}
