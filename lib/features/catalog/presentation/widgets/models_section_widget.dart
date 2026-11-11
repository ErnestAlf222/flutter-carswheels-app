import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
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
        switch (current) {
          ModelsInitial() => const SizedBox.shrink(),
          ModelsLoading() => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: AppLoader()),
          ),
          ModelsError() => ErrorStateWidget(
            onRetry: context.read<ModelsCubit>().retry,
          ),
          ModelsLoaded(:final models) when models.isEmpty =>
            const EmptyStateWidget(),
          ModelsLoaded(:final models, :final visibleCount) => Column(
            children: [
              for (int index = 0; index < visibleCount; index++) ...[
                if (index > 0) const SizedBox(height: AppSpacing.s),
                ModelCardWidget(name: models[index].name, index: index),
              ],
            ],
          ),
        },
      ],
    );
  }
}
