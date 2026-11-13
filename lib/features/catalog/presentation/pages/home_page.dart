import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

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
            context.read<SummariesCubit>().cancelPending();
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
          listener: _requestPhotosAndSummaries,
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
                CatalogInitial() || CatalogLoading() => const CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoader(),
                    ),
                  ],
                ),
                CatalogError() => CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorStateWidget(
                        onRetry: context.read<CatalogCubit>().retry,
                      ),
                    ),
                  ],
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
        !identical(previous.groups, current.groups) ||
        previous.visibleCount != current.visibleCount ||
        previous.isRefreshing ||
        previous.year != current.year ||
        previous.brand != current.brand;
  }

  // Pide fotos y resúmenes de los grupos visibles, en el orden de la lista.
  static void _requestPhotosAndSummaries(
    BuildContext context,
    ModelsState state,
  ) {
    if (state is! ModelsLoaded) return;
    _requestPhotos(context, state);
    _requestSummaries(context, state);
  }

  // Pide las fotos visibles que aún no se pidieron, en el orden de la lista.
  static void _requestPhotos(BuildContext context, ModelsLoaded state) {
    final photos = context.read<PhotosCubit>();
    final requests = <PhotoRequest>[
      for (final group in state.groups.take(state.visibleCount))
        PhotoRequest(brand: state.brand, model: group.name, year: state.year),
    ];
    final missing = requests.where((request) {
      final slot = photos.state.slots[photos.keyFor(request)];
      return slot == null || slot is PhotoFailed;
    }).toList();
    if (missing.isEmpty) return;
    photos.requestPhotos(missing);
  }

  // Pide los resúmenes visibles que aún no se pidieron o fallaron.
  static void _requestSummaries(BuildContext context, ModelsLoaded state) {
    final summaries = context.read<SummariesCubit>();
    final requests = <SummaryRequest>[
      for (final group in state.groups.take(state.visibleCount))
        SummaryRequest(
          brand: state.brand,
          groupName: group.name,
          year: state.year,
          variantNames: group.variants.map((variant) => variant.name).toList(),
        ),
    ];
    final missing = requests.where((request) {
      final slot =
          summaries.state.slots[summaries.keyFor(
            request.brand,
            request.groupName,
            request.year,
          )];
      return slot == null || slot is SummaryFailed;
    }).toList();
    if (missing.isEmpty) return;
    summaries.requestSummaries(missing);
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

  // Abre Detalle con lo que la lista ya sabe del grupo, incluida su foto.
  static void _openDetail(
    BuildContext context,
    ModelsLoaded state,
    ModelGroupEntity group,
  ) {
    final photos = context.read<PhotosCubit>();
    final heroTag = photos.keyFor(
      PhotoRequest(brand: state.brand, model: group.name, year: state.year),
    );
    final slot = photos.state.slots[heroTag];
    final args = DetailArgsEntity(
      brand: state.brand,
      groupName: group.name,
      year: state.year,
      variantNames: [for (final variant in group.variants) variant.name],
      photo: slot is PhotoFound ? slot.photo : null,
      heroTag: heroTag,
    );
    context.push(RoutesConfig.detail, extra: args);
  }

  // Pide la siguiente página cuando el scroll se acerca al final.
  static void _loadMoreNearEnd(
    BuildContext context,
    ScrollNotification notification,
  ) {
    // El carrusel horizontal no pagina la lista.
    if (notification.metrics.axis != Axis.vertical) return;
    if (notification.metrics.extentAfter >=
        CatalogConfig.loadMoreThresholdPixels) {
      return;
    }
    final cubit = context.read<ModelsCubit>();
    final state = cubit.state;
    if (state is ModelsLoaded && state.visibleCount < state.groups.length) {
      cubit.loadMore();
    }
  }
}

/// Contenido de la pantalla con las marcas cargadas.
class _LoadedContent extends StatefulWidget {
  const _LoadedContent({required this.state});

  final CatalogLoaded state;

  @override
  State<_LoadedContent> createState() => _LoadedContentState();
}

class _LoadedContentState extends State<_LoadedContent>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<CatalogCubit>();
    final hasBrands = state.brands.isNotEmpty;
    final snapDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: AnimationConfig.headerSnapMilliseconds);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.m,
            ),
            child: Text(AppConfig.appName, style: AppTextStyles.cardTitle),
          ),
        ),
        if (hasBrands)
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: BrandHeaderDelegate(
              year: state.year,
              availableYears: state.availableYears,
              brandCount: state.brands.length,
              selectedIndex: state.selectedIndex,
              windowStart: state.windowStart,
              brandName: state.brands[state.selectedIndex].name,
              isRefreshing: state.isRefreshing,
              snapDuration: snapDuration,
              onOlderYear: cubit.showOlderYear,
              onNewerYear: cubit.showNewerYear,
              vsync: this,
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _BrandsHeader(state: state),
            ),
          ),
        if (state.refreshFailure != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.m,
                AppSpacing.xl,
                0,
              ),
              child: InlineMessageWidget(
                message: AppTexts.refreshFailedLabel,
                actionLabel: AppTexts.retryButtonLabel,
                onAction: cubit.retry,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.m,
              AppSpacing.xl,
              0,
            ),
            child: RefreshableContentWidget(
              isRefreshing: state.isRefreshing,
              child: hasBrands
                  ? BlocBuilder<ModelsCubit, ModelsState>(
                      builder: (context, modelsState) => ModelsSectionWidget(
                        brandName: state.brands[state.selectedIndex].name,
                        state: modelsState,
                        onGroupTap: modelsState is ModelsLoaded
                            ? (group) => HomePage._openDetail(
                                context,
                                modelsState,
                                group,
                              )
                            : null,
                      ),
                    )
                  : const EmptyStateWidget(),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: UiConfig.navClearance),
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
