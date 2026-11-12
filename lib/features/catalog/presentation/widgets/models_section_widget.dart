import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_card_skeleton_widget.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/model_card_widget.dart';

/// Sección con el nombre de la marca y la lista de sus modelos.
class ModelsSectionWidget extends StatelessWidget {
  const ModelsSectionWidget({
    super.key,
    required this.brandName,
    required this.state,
  });

  final String brandName;
  final ModelsState state;

  @override
  Widget build(BuildContext context) {
    final current = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                brandName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionTitle,
              ),
            ),
            if (current is ModelsLoaded)
              Text(
                AppTexts.modelsCountLabel(current.models.length),
                style: AppTextStyles.caption,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        _FadeSwitcher(child: _body(context, current)),
      ],
    );
  }

  // Contenido según el estado; la llave define cuándo hay fundido.
  Widget _body(BuildContext context, ModelsState current) => switch (current) {
    ModelsInitial() => const SizedBox.shrink(key: ValueKey('initial')),
    ModelsLoading() => const _SkeletonList(key: ValueKey('loading')),
    ModelsError() => ErrorStateWidget(
      key: const ValueKey('error'),
      onRetry: context.read<ModelsCubit>().retry,
    ),
    ModelsLoaded(:final models) when models.isEmpty => const EmptyStateWidget(
      key: ValueKey('empty'),
    ),
    ModelsLoaded() => _LoadedList(
      key: ValueKey('${current.year}-${current.brand}'),
      state: current,
    ),
  };
}

/// Fundido de toda la columna al cambiar de contenido.
class _FadeSwitcher extends StatelessWidget {
  const _FadeSwitcher({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.fadeDurationMilliseconds,
          );
    return AnimatedSwitcher(
      duration: duration,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: child,
    );
  }
}

/// Esqueletos que ocupan el lugar de las tarjetas mientras carga.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < UiConfig.skeletonCardCount; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.s),
          const ModelCardSkeletonWidget(),
        ],
      ],
    );
  }
}

/// Tarjetas visibles, atenuadas mientras se refresca la lista.
class _LoadedList extends StatelessWidget {
  const _LoadedList({super.key, required this.state});

  final ModelsLoaded state;

  @override
  Widget build(BuildContext context) {
    final failure = state.refreshFailure;
    return Column(
      children: [
        if (failure != null)
          InlineMessageWidget(
            message: AppTexts.refreshFailedLabel,
            actionLabel: AppTexts.retryButtonLabel,
            onAction: context.read<ModelsCubit>().retry,
          ),
        RefreshableContentWidget(
          isRefreshing: state.isRefreshing,
          child: Column(
            children: [
              for (int index = 0; index < state.visibleCount; index++) ...[
                if (index > 0) const SizedBox(height: AppSpacing.s),
                ModelCardWidget(
                  name: state.models[index].name,
                  brand: state.brand,
                  year: state.year,
                  index: index,
                  // La primera página entra con el fundido de la columna.
                  animateEntry: index >= CatalogConfig.defaultPageSize,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
