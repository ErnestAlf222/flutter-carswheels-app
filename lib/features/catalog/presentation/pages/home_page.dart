import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';

/// Pantalla de inicio con el carrusel de marcas y sus modelos.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CatalogCubit, CatalogState>(
      listenWhen: _shouldLoadModels,
      listener: (context, state) {
        if (state is! CatalogLoaded) return;
        context.read<ModelsCubit>().load(
          state.year,
          state.brands[state.selectedIndex].name,
        );
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _loadMoreNearEnd(context, notification);
          // Devuelve false para que el menú flotante también la reciba.
          return false;
        },
        child: Scaffold(
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
                const _BrandsHeader(),
                const SizedBox(height: AppSpacing.m),
                const _BrandsCarousel(),
                const SizedBox(height: AppSpacing.xl),
                const _ModelsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Solo carga modelos si cambió el año o la marca seleccionada.
  static bool _shouldLoadModels(CatalogState previous, CatalogState current) {
    if (current is! CatalogLoaded || current.brands.isEmpty) return false;
    if (previous is! CatalogLoaded || previous.brands.isEmpty) return true;
    return previous.year != current.year ||
        previous.brands[previous.selectedIndex].name !=
            current.brands[current.selectedIndex].name;
  }

  // Pide la siguiente página cuando el scroll se acerca al final.
  static void _loadMoreNearEnd(
    BuildContext context,
    ScrollNotification notification,
  ) {
    if (notification.metrics.extentAfter >=
        CatalogConfig.loadMoreThresholdPixels) {
      return;
    }
    final cubit = context.read<ModelsCubit>();
    final state = cubit.state;
    if (state is ModelsLoaded && state.visibleCount < state.models.length) {
      cubit.loadMore();
    }
  }
}

/// Título de marcas con el selector de año.
class _BrandsHeader extends StatelessWidget {
  const _BrandsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppTexts.brandsSectionTitle,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            if (state is! CatalogLoaded) return const SizedBox.shrink();
            final cubit = context.read<CatalogCubit>();
            final yearIndex = state.availableYears.indexOf(state.year);
            return YearSelectorWidget(
              year: state.year,
              canShowOlder: yearIndex < state.availableYears.length - 1,
              canShowNewer: yearIndex > 0,
              onOlder: cubit.showOlderYear,
              onNewer: cubit.showNewerYear,
            );
          },
        ),
      ],
    );
  }
}

/// Carrusel de marcas según el estado del catálogo.
class _BrandsCarousel extends StatelessWidget {
  const _BrandsCarousel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) => switch (state) {
        CatalogInitial() || CatalogLoading() => const AppLoader(),
        CatalogError() => ErrorStateWidget(
          onRetry: context.read<CatalogCubit>().retry,
        ),
        CatalogLoaded(:final brands) =>
          brands.isEmpty
              ? const EmptyStateWidget()
              : const BrandCarouselWidget(),
      },
    );
  }
}

/// Modelos de la marca seleccionada.
class _ModelsSection extends StatelessWidget {
  const _ModelsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, catalogState) {
        if (catalogState is! CatalogLoaded || catalogState.brands.isEmpty) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<ModelsCubit, ModelsState>(
          builder: (context, modelsState) => ModelsSectionWidget(
            brandName: catalogState.brands[catalogState.selectedIndex].name,
            state: modelsState,
          ),
        );
      },
    );
  }
}
