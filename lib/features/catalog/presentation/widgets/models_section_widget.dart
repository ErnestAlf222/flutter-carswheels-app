import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_grid_card_skeleton_widget.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_grid_card_widget.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_grid_sliver_widget.dart';

/// Sliver con el nombre de la marca y la cuadrícula de sus modelos.
class ModelsSectionWidget extends StatelessWidget {
  const ModelsSectionWidget({
    super.key,
    required this.brandName,
    required this.state,
    this.onGroupTap,
  });

  final String brandName;
  final ModelsState state;

  /// Al tocar la tarjeta de un grupo.
  final ValueChanged<ModelGroupEntity>? onGroupTap;

  @override
  Widget build(BuildContext context) {
    final current = state;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: UiConfig.titleUnderlineGap),
                      const _TitleUnderline(),
                    ],
                  ),
                ),
                if (current is ModelsLoaded)
                  Text(
                    AppTexts.modelsCountLabel(current.groups.length),
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
        ),
        _FadeIn(
          key: ValueKey(_bodyKey(current)),
          sliver: _body(context, current),
        ),
      ],
    );
  }

  // Llave del contenido; al cambiar, el nuevo contenido entra con fundido.
  String _bodyKey(ModelsState current) => switch (current) {
    ModelsInitial() => 'initial',
    ModelsLoading() => 'loading',
    ModelsError() => 'error',
    ModelsLoaded(:final groups) when groups.isEmpty => 'empty',
    ModelsLoaded() => '${current.year}-${current.brand}',
  };

  Widget _body(BuildContext context, ModelsState current) => switch (current) {
    ModelsInitial() => const SliverToBoxAdapter(child: SizedBox.shrink()),
    ModelsLoading() => const _SkeletonGrid(),
    ModelsError() => SliverToBoxAdapter(
      child: ErrorStateWidget(onRetry: context.read<ModelsCubit>().retry),
    ),
    ModelsLoaded(:final groups) when groups.isEmpty => const SliverToBoxAdapter(
      child: EmptyStateWidget(),
    ),
    ModelsLoaded() => _LoadedGrid(state: current, onGroupTap: onGroupTap),
  };
}

/// Fundido de entrada del contenido de un sliver; se reinicia al cambiar su llave.
class _FadeIn extends StatelessWidget {
  const _FadeIn({super.key, required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.fadeDurationMilliseconds,
          );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      builder: (context, opacity, child) =>
          SliverOpacity(opacity: opacity, sliver: child),
      child: sliver,
    );
  }
}

/// Esqueletos que ocupan el lugar de las tarjetas mientras carga.
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return ModelGridSliver(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ModelGridCardSkeletonWidget(),
        childCount: ModelGridConfig.skeletonCardCount,
      ),
    );
  }
}

/// Tarjetas visibles de la cuadrícula; solo se construyen las que se ven.
class _LoadedGrid extends StatelessWidget {
  const _LoadedGrid({required this.state, this.onGroupTap});

  final ModelsLoaded state;
  final ValueChanged<ModelGroupEntity>? onGroupTap;

  @override
  Widget build(BuildContext context) {
    final failure = state.refreshFailure;
    return SliverMainAxisGroup(
      slivers: [
        if (failure != null)
          SliverToBoxAdapter(
            child: InlineMessageWidget(
              message: AppTexts.refreshFailedLabel,
              actionLabel: AppTexts.retryButtonLabel,
              onAction: context.read<ModelsCubit>().retry,
            ),
          ),
        ModelGridSliver(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ModelGridCardWidget(
              group: state.groups[index],
              brand: state.brand,
              year: state.year,
              index: index,
              onTap: onGroupTap == null
                  ? null
                  : () => onGroupTap!(state.groups[index]),
              // La primera página entra con el fundido de la sección.
              animateEntry: index >= CatalogConfig.defaultPageSize,
            ),
            childCount: state.visibleCount,
          ),
        ),
      ],
    );
  }
}

/// Subrayado corto amarillo bajo el título de la marca.
class _TitleUnderline extends StatelessWidget {
  const _TitleUnderline();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SizedBox(
        width: UiConfig.titleUnderlineWidth,
        height: UiConfig.titleUnderlineHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.all(
              Radius.circular(UiConfig.titleUnderlineHeight),
            ),
          ),
        ),
      ),
    );
  }
}
