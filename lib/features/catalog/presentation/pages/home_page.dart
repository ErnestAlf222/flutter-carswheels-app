import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Pantalla de inicio con el carrusel de marcas y sus modelos.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onSearchTap});

  /// Lleva a la sección de búsqueda con el teclado enfocado; lo define la capa app.
  final void Function(BuildContext context) onSearchTap;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CatalogCubit, CatalogState>(
          listenWhen: (previous, current) => _isReady(current),
          listener: (context, _) => _syncModels(context),
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
      child: HomeEntrySync(
        onEnter: _syncOnEnter,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _loadMoreNearEnd(context, notification);
            // Devuelve false para que el menú flotante también la reciba.
            return false;
          },
          child: Scaffold(
            // El fondo con degradado lo pone el marco de la app.
            backgroundColor: Colors.transparent,
            // Un solo árbol para todos los estados: el encabezado no se reconstruye.
            body: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) =>
                  _HomeContent(state: state, onSearchTap: onSearchTap),
            ),
          ),
        ),
      ),
    );
  }

  // Catálogo con marcas, sin cambio de año, recarga ni fallo en curso.
  static bool _isReady(CatalogState state) =>
      state is CatalogLoaded &&
      state.brands.isNotEmpty &&
      !state.isRefreshing &&
      !state.isReloading &&
      state.refreshFailure == null;

  // La lista de modelos debe corresponder a la marca y año del catálogo.
  static void _syncModels(BuildContext context) {
    final catalog = context.read<CatalogCubit>().state;
    if (catalog is! CatalogLoaded || !_isReady(catalog)) return;
    final models = context.read<ModelsCubit>();
    final brand = catalog.brands[catalog.selectedIndex].name;
    if (!models.needsLoad(catalog.year, brand)) return;
    // Lo que no empezó con la selección anterior ya no hace falta.
    context.read<PhotosCubit>().cancelPending();
    context.read<SummariesCubit>().cancelPending();
    unawaited(models.load(catalog.year, brand));
  }

  // Al mostrarse: el catálogo pudo cambiar mientras la pantalla estaba fuera.
  static void _syncOnEnter(BuildContext context) {
    _syncModels(context);
    final models = context.read<ModelsCubit>().state;
    if (models is ModelsLoaded &&
        !models.isRefreshing &&
        models.refreshFailure == null) {
      _requestPhotosAndSummaries(context, models);
    }
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
    final cachedPhoto = slot is PhotoFound ? slot.photo : null;
    if (cachedPhoto != null) {
      // La foto grande baja mientras se abre Detalle; no se espera.
      unawaited(
        context.read<PhotoPrefetcher>().prefetchLarge(context, cachedPhoto),
      );
    }
    final args = DetailArgsEntity(
      brand: state.brand,
      groupName: group.name,
      year: state.year,
      variantNames: [for (final variant in group.variants) variant.name],
      photo: cachedPhoto,
      heroTag: heroTag,
      market: context.read<MarketCubit>().market,
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

/// Contenido de la pantalla; el encabezado persiste en todos los estados.
class _HomeContent extends StatefulWidget {
  const _HomeContent({required this.state, required this.onSearchTap});

  final CatalogState state;
  final void Function(BuildContext context) onSearchTap;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final loaded = state is CatalogLoaded ? state : null;
    final settled = loaded != null && !loaded.isReloading;
    final market = context.read<MarketCubit>().market;
    return RememberedScroll(
      store: context.read<ScrollOffsetStore>(),
      sectionKey: ScrollConfig.homeSectionKey,
      contextKey: '${market.code}|${settled ? loaded.year : ''}',
      builder: (context, scrollController) => Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  state: loaded,
                  onSearchTap: loaded == null
                      ? null
                      : () => widget.onSearchTap(context),
                ),
              ),
              ..._bodySlivers(context, state),
            ],
          ),
          if (settled) ScrollToTopButton(controller: scrollController),
        ],
      ),
    );
  }

  List<Widget> _bodySlivers(BuildContext context, CatalogState state) {
    return switch (state) {
      CatalogInitial() || CatalogLoading() => const [
        SliverFillRemaining(hasScrollBody: false, child: AppLoader()),
      ],
      CatalogError() => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorStateWidget(onRetry: context.read<CatalogCubit>().retry),
        ),
      ],
      // Cambio de mercado: solo la zona de contenido muestra el loader.
      CatalogLoaded(:final isReloading) when isReloading => const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
            ),
            child: _BrandsHeader(),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppLoader(compact: true),
        ),
      ],
      CatalogLoaded() => _loadedSlivers(context, state),
    };
  }

  List<Widget> _loadedSlivers(BuildContext context, CatalogLoaded state) {
    final cubit = context.read<CatalogCubit>();
    final hasBrands = state.brands.isNotEmpty;
    final snapDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: AnimationConfig.headerSnapMilliseconds);
    return [
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
            topInset: MediaQuery.paddingOf(context).top,
            onYearSelected: cubit.selectYear,
            vsync: this,
          ),
        )
      else
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
            ),
            child: _BrandsHeader(),
          ),
        ),
      if (state.refreshFailure != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UiConfig.pageHorizontalPadding,
              AppSpacing.m,
              UiConfig.pageHorizontalPadding,
              0,
            ),
            child: InlineMessageWidget(
              message: AppTexts.refreshFailedLabel,
              actionLabel: AppTexts.retryButtonLabel,
              onAction: cubit.retry,
            ),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          UiConfig.pageHorizontalPadding,
          AppSpacing.m,
          UiConfig.pageHorizontalPadding,
          0,
        ),
        sliver: RefreshableSliverWidget(
          isRefreshing: state.isRefreshing,
          sliver: hasBrands
              ? BlocBuilder<ModelsCubit, ModelsState>(
                  builder: (context, modelsState) => ModelsSectionWidget(
                    brandName: state.brands[state.selectedIndex].name,
                    state: modelsState,
                    onGroupTap: modelsState is ModelsLoaded
                        ? (group) =>
                              HomePage._openDetail(context, modelsState, group)
                        : null,
                  ),
                )
              : const SliverToBoxAdapter(child: EmptyStateWidget()),
        ),
      ),
      // Deja la última fila por encima del menú flotante y el área segura.
      SliverToBoxAdapter(
        child: SizedBox(
          height:
              NavConfig.footprint +
              MediaQuery.paddingOf(context).bottom +
              ModelGridConfig.listBottomGap,
        ),
      ),
    ];
  }
}

/// Encabezado tinta: wordmark, selector de mercado y barra de búsqueda a caballo.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.state, this.onSearchTap});

  /// Catálogo cargado; nulo mientras carga o falla (solo se ve la bandera).
  final CatalogLoaded? state;

  /// Nulo mientras no hay marcas cargadas: entonces no se muestra la barra.
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final onTap = onSearchTap;
    final topInset = MediaQuery.paddingOf(context).top;
    final hasBar = onTap != null;
    final header = HeroHeaderWidget(
      padding: EdgeInsets.only(
        top: topInset + HeaderConfig.contentTopPadding,
        bottom: hasBar
            ? HeaderConfig.contentBottomPadding + HeaderConfig.searchBarOverlap
            : HeaderConfig.contentBottomPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.pageHorizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppTexts.wordmarkFirst,
                      style: AppTextStyles.onDarkWordmark,
                    ),
                    TextSpan(
                      text: AppTexts.wordmarkSecond,
                      style: AppTextStyles.onDarkWordmarkAccent,
                    ),
                  ],
                ),
                semanticsLabel: AppConfig.appName,
              ),
            ),
            MarketYearSelectorWidget(
              years: state?.availableYears ?? const [],
              year: state?.year,
              onYearSelected: context.read<CatalogCubit>().selectYear,
            ),
          ],
        ),
      ),
    );
    if (!hasBar) return header;
    // La barra sobresale por abajo: el espacio extra la deja dentro del sliver.
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: HeaderConfig.searchBarOverlap),
          child: header,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: HomeSearchBarWidget(onTap: onTap),
        ),
      ],
    );
  }
}

/// Título de marcas; el selector de mercado y año vive solo en el encabezado.
class _BrandsHeader extends StatelessWidget {
  const _BrandsHeader();

  @override
  Widget build(BuildContext context) {
    return Text(AppTexts.brandsSectionTitle, style: AppTextStyles.sectionTitle);
  }
}
