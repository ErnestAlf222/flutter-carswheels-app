import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/widgets.dart';

/// Pantalla Comparar: encabezado, hasta 3 espacios y lo que sigue según cuántos haya.
class ComparePage extends StatefulWidget {
  const ComparePage({
    super.key,
    required this.selectorBuilder,
    required this.visuals,
    this.openPickerOnEntry = false,
  });

  /// Píldora de mercado y año del encabezado; la implementa la capa app.
  final WidgetBuilder selectorBuilder;

  /// Foto y logo de cada vehículo; los implementa la capa app.
  final CompareSlotVisuals visuals;

  /// Abre el selector al llegar (con un solo vehículo desde Detalle).
  final bool openPickerOnEntry;

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  @override
  void initState() {
    super.initState();
    // El selector se abre con la pantalla ya construida, una sola vez.
    if (widget.openPickerOnEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openPicker());
    }
  }

  void _openPicker() {
    if (!mounted) return;
    context.push<void>(RoutesConfig.comparePicker);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        NavConfig.footprint +
        MediaQuery.paddingOf(context).bottom +
        ModelGridConfig.listBottomGap;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HeroHeaderWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConfig.pageHorizontalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      // Con texto grande el título se encoge en vez de desbordar.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppTexts.comparePageTitle,
                          maxLines: 1,
                          style: AppTextStyles.onDarkScreenTitle,
                        ),
                      ),
                    ),
                    widget.selectorBuilder(context),
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<CompareCubit, CompareState>(
            builder: (context, state) => _Body(
              state: state,
              visuals: widget.visuals,
              bottomPadding: bottomPadding,
              onAdd: _openPicker,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenido bajo el encabezado según el estado de la selección.
class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.visuals,
    required this.bottomPadding,
    required this.onAdd,
  });

  final CompareState state;
  final CompareSlotVisuals visuals;
  final double bottomPadding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is! CompareLoaded) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AppLoader(compact: true),
        ),
      );
    }
    final cubit = context.read<CompareCubit>();
    final selection = current.selection;
    final notice = current.notice;
    // El grupo mantiene la banda fija solo mientras se recorre la tabla.
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            AppSpacing.m,
            UiConfig.pageHorizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NoticeSlot(notice: notice, noticeId: current.noticeId),
                // Alto fijo: el diseño no salta cuando aparece o se va "Limpiar".
                SizedBox(
                  height: CompareConfig.removeTouchSize,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppTexts.compareSlotsCountLabel(
                            selection.length,
                            CompareConfig.maxSlots,
                          ),
                          style: AppTextStyles.caption,
                        ),
                      ),
                      if (!selection.isEmpty)
                        TextButton(
                          onPressed: cubit.clear,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            minimumSize: const Size(
                              0,
                              CompareConfig.removeTouchSize,
                            ),
                          ),
                          child: Text(
                            AppTexts.compareClearLabel,
                            style: AppTextStyles.bodyStrong,
                          ),
                        ),
                    ],
                  ),
                ),
                CompareSlotsRowWidget(
                  selection: selection,
                  visuals: visuals,
                  onRemove: cubit.remove,
                  onAdd: onAdd,
                ),
                if (selection.canCompare) ...[
                  CompareVersionPillsRowWidget(
                    selection: selection,
                    versionsSource: context.read<CompareVersionsSource>(),
                  ),
                  const SizedBox(height: CompareConfig.tableTopGap),
                  Text(
                    AppTexts.compareTableTitle,
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: CompareConfig.tableSupportGap),
                  Text(
                    AppTexts.compareTableSupport,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: CompareConfig.tableBandTopGap),
                ] else ...[
                  const SizedBox(height: CompareConfig.helpTopGap),
                  CompareHelpWidget(isEmpty: selection.isEmpty, onAdd: onAdd),
                ],
              ],
            ),
          ),
        ),
        if (selection.canCompare)
          _TableSlivers(slots: selection.slots, bottomPadding: bottomPadding)
        else
          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
      ],
    );
  }
}

/// Banda fija de columnas y el cuerpo de la tabla.
class _TableSlivers extends StatelessWidget {
  const _TableSlivers({required this.slots, required this.bottomPadding});

  final List<CompareSlotEntity> slots;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: CompareTableBandDelegate(
            slots: slots,
            topInset: MediaQuery.paddingOf(context).top,
            textScaler: MediaQuery.textScalerOf(context),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            0,
            UiConfig.pageHorizontalPadding,
            bottomPadding,
          ),
          sliver: SliverToBoxAdapter(
            // Solo la tabla se reconstruye cuando llegan datos de una columna.
            child: BlocBuilder<CompareTableCubit, CompareTableState>(
              builder: (context, table) => CompareTableWidget(
                slots: slots,
                table: table,
                onRetry: context.read<CompareTableCubit>().retry,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Espacio del mensaje breve: crece y se encoge, o aparece sin animar.
class _NoticeSlot extends StatelessWidget {
  const _NoticeSlot({required this.notice, required this.noticeId});

  final CompareNotice? notice;
  final int noticeId;

  @override
  Widget build(BuildContext context) {
    final current = notice;
    final slot = current == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: CompareNoticeWidget(
              key: ValueKey(noticeId),
              notice: current,
            ),
          );
    // AnimatedSize no admite duración cero: sin animaciones se omite.
    if (MediaQuery.of(context).disableAnimations) return slot;
    return AnimatedSize(
      duration: const Duration(
        milliseconds: AnimationConfig.fadeDurationMilliseconds,
      ),
      alignment: Alignment.topCenter,
      child: slot,
    );
  }
}
