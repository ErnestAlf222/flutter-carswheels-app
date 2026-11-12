import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Pantalla de inicio con el carrusel de marcas y sus modelos.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CatalogCubit, CatalogState>(
          listenWhen: _shouldLoadModels,
          listener: (context, state) {
            if (state is! CatalogLoaded) return;
            // Lo que no empezó con la selección anterior ya no hace falta.
            context.read<PhotosCubit>().cancelPending();
            context.read<ModelsCubit>().load(
              state.year,
              state.brands[state.selectedIndex].name,
            );
          },
        ),
        BlocListener<CatalogCubit, CatalogState>(
          listenWhen: (previous, current) => current is CatalogLoaded,
          listener: (context, _) => _precacheLogos(context),
        ),
        const BlocListener<ModelsCubit, ModelsState>(
          listenWhen: _shouldRequestPhotos,
          listener: _requestPhotos,
        ),
        BlocListener<BrandLogosCubit, BrandLogosState>(
          listenWhen: (previous, current) => current is BrandLogosLoaded,
          listener: (context, _) => _precacheLogos(context),
        ),
      ],
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _loadMoreNearEnd(context, notification);
          // Devuelve false para que el menú flotante también la reciba.
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) => switch (state) {
                CatalogInitial() || CatalogLoading() => const AppLoader(),
                CatalogError() => ErrorStateWidget(
                  onRetry: context.read<CatalogCubit>().retry,
                ),
                CatalogLoaded() => _LoadedContent(state: state),
              },
            ),
          ),
        ),
      ),
    );
  }

  // Solo carga modelos si cambió el año o la marca seleccionada.
  static bool _shouldLoadModels(CatalogState previous, CatalogState current) {
    if (current is! CatalogLoaded || current.brands.isEmpty) return false;
    if (current.isRefreshing || current.refreshFailure != null) return false;
    if (previous is! CatalogLoaded || previous.brands.isEmpty) return true;
    return previous.year != current.year ||
        previous.brands[previous.selectedIndex].name !=
            current.brands[current.selectedIndex].name;
  }

  // Pide fotos solo con una lista cargada y sin refresco en curso o fallido.
  static bool _shouldRequestPhotos(ModelsState previous, ModelsState current) {
    if (current is! ModelsLoaded) return false;
    if (current.isRefreshing || current.refreshFailure != null) return false;
    return previous is! ModelsLoaded ||
        !identical(previous.models, current.models) ||
        previous.visibleCount != current.visibleCount ||
        previous.isRefreshing ||
        previous.year != current.year ||
        previous.brand != current.brand;
  }

  // Pide las fotos visibles que aún no se pidieron, en el orden de la lista.
  static void _requestPhotos(BuildContext context, ModelsState state) {
    if (state is! ModelsLoaded) return;
    final photos = context.read<PhotosCubit>();
    final requests = <PhotoRequest>[
      for (final model in state.models.take(state.visibleCount))
        PhotoRequest(brand: state.brand, model: model.name, year: state.year),
    ];
    final missing = requests.where((request) {
      final slot = photos.state.slots[photos.keyFor(request)];
      return slot == null || slot is PhotoFailed;
    }).toList();
    if (missing.isEmpty) return;
    photos.requestPhotos(missing);
  }

  // Precarga los logos de las primeras marcas cuando marcas y logos están.
  static void _precacheLogos(BuildContext context) {
    final catalog = context.read<CatalogCubit>().state;
    final logos = context.read<BrandLogosCubit>();
    if (catalog is! CatalogLoaded || logos.state is! BrandLogosLoaded) return;
    final urls = <String>[
      for (final brand in catalog.brands.take(
        CarouselConfig.logoPrecacheMaxItems,
      ))
        ?logos.urlFor(brand.name),
    ];
    context.read<LogoPrecacheCubit>().precache(context, urls);
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

/// Contenido de la pantalla con las marcas cargadas.
class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.state});

  final CatalogLoaded state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        UiConfig.navClearance,
      ),
      children: [
        Text(AppConfig.appName, style: AppTextStyles.cardTitle),
        const SizedBox(height: AppSpacing.xl),
        RefreshableContentWidget(
          isRefreshing: state.isRefreshing,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BrandsHeader(state: state),
              if (state.refreshFailure != null)
                InlineMessageWidget(
                  message: AppTexts.refreshFailedLabel,
                  actionLabel: AppTexts.retryButtonLabel,
                  onAction: context.read<CatalogCubit>().retry,
                ),
              const SizedBox(height: AppSpacing.m),
              if (state.brands.isEmpty)
                const EmptyStateWidget()
              else ...[
                const BrandCarouselWidget(),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<ModelsCubit, ModelsState>(
                  builder: (context, modelsState) => ModelsSectionWidget(
                    brandName: state.brands[state.selectedIndex].name,
                    state: modelsState,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Título de marcas con el selector de año.
class _BrandsHeader extends StatelessWidget {
  const _BrandsHeader({required this.state});

  final CatalogLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    final yearIndex = state.availableYears.indexOf(state.year);
    return Row(
      children: [
        Expanded(
          child: Text(
            AppTexts.brandsSectionTitle,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        YearSelectorWidget(
          year: state.year,
          canShowOlder: yearIndex < state.availableYears.length - 1,
          canShowNewer: yearIndex > 0,
          onOlder: cubit.showOlderYear,
          onNewer: cubit.showNewerYear,
        ),
      ],
    );
  }
}
