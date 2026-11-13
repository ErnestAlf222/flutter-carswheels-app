import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Pantalla Detalle de un grupo de modelos.
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.args});

  final DetailArgsEntity args;

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
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: DetailHeroHeaderWidget(args: args)),
                SliverToBoxAdapter(child: _DetailBody(args: args)),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DetailBottomBarWidget(
                onCompare: () => context.go(RoutesConfig.compare),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        final classLabel = loaded == null
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
            const SizedBox(height: UiConfig.detailBottomClearance),
          ],
        );
      },
    );
  }

  // Contenido según el estado; la llave define cuándo hay fundido.
  Widget _content(BuildContext context, DetailState state) => switch (state) {
    DetailInitial() ||
    DetailLoading() => const DetailSkeletonWidget(key: ValueKey('loading')),
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
      child: ErrorStateWidget(onRetry: context.read<DetailCubit>().retry),
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
    return Column(
      children: [
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
              child: DetailStatsCardWidget(detail: detail),
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
