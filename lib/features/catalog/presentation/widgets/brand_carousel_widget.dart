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
        // La entrada es de la fila completa y ocurre solo al aparecer.
        return AnimatedEntryWidget(
          index: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArrowButton(
                icon: Symbols.chevron_left,
                label: AppTexts.previousBrandsLabel,
                onPressed: cubit.showPreviousBrands,
              ),
              Expanded(child: _BrandsRow(state: state)),
              _ArrowButton(
                icon: Symbols.chevron_right,
                label: AppTexts.nextBrandsLabel,
                onPressed: cubit.showNextBrands,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Marcas de la ventana actual; cambian con un fundido de toda la fila.
class _BrandsRow extends StatelessWidget {
  const _BrandsRow({required this.state});

  final CatalogLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    final brandCount = state.brands.length;
    final visibleCount = math.min(CarouselConfig.visibleBrandCount, brandCount);
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: CarouselConfig.shiftFadeMilliseconds);
    return AnimatedSwitcher(
      duration: duration,
      child: Row(
        key: ValueKey('${state.year}-${state.windowStart}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int position = 0; position < visibleCount; position++)
            Expanded(
              key: ValueKey((state.windowStart + position) % brandCount),
              child: Center(
                child: BrandTileWidget(
                  brandName: state
                      .brands[(state.windowStart + position) % brandCount]
                      .name,
                  selected:
                      (state.windowStart + position) % brandCount ==
                      state.selectedIndex,
                  onTap: () => cubit.selectBrand(
                    (state.windowStart + position) % brandCount,
                  ),
                ),
              ),
            ),
        ],
      ),
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
      child: SizedBox(
        width: CarouselConfig.arrowTouchTargetSize,
        height: CarouselConfig.arrowTouchTargetSize,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Center(
              child: Container(
                width: CarouselConfig.arrowButtonSize,
                height: CarouselConfig.arrowButtonSize,
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(
                  icon,
                  size: CarouselConfig.arrowIconSize,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
