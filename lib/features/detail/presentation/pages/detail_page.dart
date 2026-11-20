import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Pide comparar el vehículo de Detalle; lo implementa la capa app.
///
/// [versionKey] es la versión elegida; nulo si aún no cargó (la predeterminada).
typedef DetailCompareHandler = void Function(
  BuildContext context,
  DetailArgsEntity args,
  String? versionKey,
);

/// Arma el corazón de la barra inferior; lo implementa la capa app.
typedef DetailFavoriteButtonBuilder = Widget Function(
  BuildContext context,
  DetailArgsEntity args,
);

/// Pantalla Detalle de un grupo de modelos.
class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.args,
    required this.onCompare,
    this.favoriteButtonBuilder,
  });

  final DetailArgsEntity args;
  final DetailCompareHandler onCompare;

  /// Corazón de favoritos; sin él la barra muestra el corazón sin acción.
  final DetailFavoriteButtonBuilder? favoriteButtonBuilder;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DetailCubit>(
          create: (context) =>
              DetailCubit(context.read<LoadGroupDetailsUseCase>())..load(args),
        ),
        BlocProvider<DetailGalleryCubit>(
          create: (context) =>
              DetailGalleryCubit(context.read<ResolveModelGalleryUseCase>())
                ..load(args),
        ),
        // NHTSA solo cubre EE. UU.: en México no se crea ni se consulta.
        if (args.market != Market.mexico)
          BlocProvider<DetailSafetyCubit>(
            create: (context) =>
                DetailSafetyCubit(context.read<ResolveGroupSafetyUseCase>())
                  ..load(args),
          ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Builder(
          builder: (context) => ConnectivityRestoreListener(
            onRestored: () => _restore(context),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: DetailHeaderDelegate(
                        brandName: args.brand,
                        groupName: args.groupName,
                        heroTag: args.heroTag,
                        topInset: MediaQuery.paddingOf(context).top,
                      ),
                    ),
                    const ConnectivityBandSliver(),
                    SliverToBoxAdapter(child: _DetailBody(args: args)),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // El contexto interno ve el DetailCubit para leer la versión elegida.
                  child: Builder(
                    builder: (context) => DetailBottomBarWidget(
                      favoriteButton: favoriteButtonBuilder?.call(
                        context,
                        args,
                      ),
                      onCompare: () => onCompare(
                        context,
                        args,
                        _selectedVersionKey(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Recarga una sola vez lo que quedó sin cargar por falta de red.
  void _restore(BuildContext context) {
    final detail = context.read<DetailCubit>();
    if (detail.state is DetailError || detail.state is DetailEmpty) {
      detail.retry();
    }
    final gallery = context.read<DetailGalleryCubit>();
    if (gallery.state.photos.length <= 1) gallery.load(args);
    if (args.market != Market.mexico) {
      context.read<DetailSafetyCubit>().retryFailed(args);
    }
  }
}

// Versión elegida en pantalla; nula mientras las versiones no cargan.
String? _selectedVersionKey(BuildContext context) {
  final state = context.read<DetailCubit>().state;
  return state is DetailLoaded
      ? state.details.versions[state.selectedIndex].variantName
      : null;
}

// Entrada escalonada de una sección; solo anima al montarse por primera vez.
Widget _entry(int index, Widget child) => AnimatedEntryWidget(
  index: index,
  stepMilliseconds: UiConfig.detailEntryStepMilliseconds,
  child: child,
);

/// Fila de título y contenido según el estado de la carga.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.args});

  final DetailArgsEntity args;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, DetailState>(
      builder: (context, state) {
        final loaded = state is DetailLoaded ? state : null;
        final isMexico = args.market == Market.mexico;
        // En México no hay clase de vehículo.
        final classLabel = loaded == null || isMexico
            ? null
            : context.read<VehicleClassTranslator>().labelFor(
                loaded
                    .details
                    .versions[loaded.selectedIndex]
                    .detail
                    .vehicleClass,
              );
        return Column(
          children: [
            _entry(
              0,
              DetailTitleRowWidget(
                brand: args.brand,
                year: args.year,
                groupName: args.groupName,
                classLabel: classLabel,
              ),
            ),
            _FadeSwitcher(child: _content(context, state)),
            if (isMexico && loaded != null)
              _entry(5, const DetailAttributionWidget()),
            // Deja el final por encima de la barra inferior y el área segura.
            SizedBox(
              height:
                  UiConfig.detailBottomClearance +
                  MediaQuery.paddingOf(context).bottom,
            ),
          ],
        );
      },
    );
  }

  // Contenido según el estado; la llave define cuándo hay fundido.
  Widget _content(BuildContext context, DetailState state) => switch (state) {
    DetailInitial() ||
    DetailLoading() => const DetailSkeletonWidget(key: ValueKey('loading')),
    DetailLoaded() when args.market == Market.mexico => _MexicoLoadedContent(
      key: const ValueKey('loaded'),
      state: state,
    ),
    DetailLoaded() => _LoadedContent(
      key: const ValueKey('loaded'),
      state: state,
    ),
    DetailEmpty() => const Padding(
      key: ValueKey('empty'),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: EmptyStateWidget(),
    ),
    DetailError() => Padding(
      key: const ValueKey('error'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: ConnectivityErrorStateWidget(
        onRetry: context.read<DetailCubit>().retry,
      ),
    ),
  };
}

/// Botón de versión, cifras y filas de la versión seleccionada.
class _LoadedContent extends StatelessWidget {
  const _LoadedContent({super.key, required this.state});

  final DetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final versions = state.details.versions;
    final version = versions[state.selectedIndex];
    final detail = version.detail;
    final descriptor = context.read<VersionDescriptorBuilder>().describe(
      detail,
    );
    // Los recalls cargan aparte; solo cambia la fila, no el resto del contenido.
    final recalls = context
        .select<DetailSafetyCubit, SafetyLoad<RecallSummaryEntity>>(
          (cubit) => cubit.state.recalls,
        );
    return Column(
      children: [
        const DetailOfflineNoticeWidget(),
        _entry(
          1,
          VersionSelectorButtonWidget(
            versionCount: versions.length,
            descriptor: descriptor.isEmpty ? version.variantName : descriptor,
            enabled: versions.length > 1,
            onTap: () => showVersionSheet(
              context,
              versions: versions,
              selectedIndex: state.selectedIndex,
              onSelected: context.read<DetailCubit>().select,
            ),
          ),
        ),
        // El cambio de versión solo desvanece; la entrada no se repite.
        _entry(
          2,
          _FadeSwitcher(
            child: KeyedSubtree(
              key: ValueKey(state.selectedIndex),
              child:
                  BlocSelector<
                    DetailSafetyCubit,
                    DetailSafetyState,
                    SafetyLoad<GroupSafetyEntity>
                  >(
                    selector: (state) => state.ratings,
                    builder: (context, ratings) =>
                        DetailStatsCardWidget(detail: detail, safety: ratings),
                  ),
            ),
          ),
        ),
        _entry(
          3,
          _FadeSwitcher(
            child: KeyedSubtree(
              key: ValueKey(state.selectedIndex),
              child: DetailInfoRowsWidget(
                classLabel: context.read<VehicleClassTranslator>().labelFor(
                  detail.vehicleClass,
                ),
                fuelLabel: context.read<FuelTypeLabeler>().labelFor(
                  detail.fuelType,
                ),
                driveLabel: context.read<DriveLabeler>().labelFor(detail.drive),
                recalls: recalls,
                onRecallsTap: recalls is SafetyData<RecallSummaryEntity>
                    ? () => showRecallsSheet(context, summary: recalls.value)
                    : null,
                beforeRecalls: _entry(
                  4,
                  _FadeSwitcher(
                    child: KeyedSubtree(
                      key: ValueKey(state.selectedIndex),
                      child: DetailEfficiencyCardWidget(detail: detail),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Contenido de México: versión, cifras, emisiones y filas, sin seguridad ni puntajes.
class _MexicoLoadedContent extends StatelessWidget {
  const _MexicoLoadedContent({super.key, required this.state});

  final DetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final versions = state.details.versions;
    final version = versions[state.selectedIndex];
    final detail = version.detail;
    return Column(
      children: [
        _entry(
          1,
          VersionSelectorButtonWidget(
            versionCount: versions.length,
            descriptor: version.label ?? version.variantName,
            enabled: versions.length > 1,
            onTap: () => showVersionSheet(
              context,
              versions: versions,
              selectedIndex: state.selectedIndex,
              onSelected: context.read<DetailCubit>().select,
            ),
          ),
        ),
        // El cambio de versión solo desvanece; la entrada no se repite.
        _entry(
          2,
          _FadeSwitcher(
            child: KeyedSubtree(
              key: ValueKey(state.selectedIndex),
              child: Column(
                children: [
                  DetailMxFiguresCardWidget(detail: detail),
                  DetailMxInfoRowsWidget(detail: detail),
                  // Mismo margen lateral que la tarjeta de consumo de EE. UU.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConfig.detailInfoSideMargin,
                    ),
                    child: DetailEmissionsCardWidget(detail: detail),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fundido corto entre contenidos, sin saltos de altura bruscos.
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
