import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';

/// Pantalla de inicio con el carrusel de marcas.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            UiConfig.navClearance,
          ),
          children: [
            Text(AppConfig.appName, style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppTexts.brandsSectionTitle,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.m),
            BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) => switch (state) {
                CatalogInitial() || CatalogLoading() => const AppLoader(),
                CatalogError() => ErrorStateWidget(
                  onRetry: context.read<CatalogCubit>().loadBrands,
                ),
                CatalogLoaded(:final brands) =>
                  brands.isEmpty
                      ? const EmptyStateWidget()
                      : const BrandCarouselWidget(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
