import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/widgets.dart';

/// Abre el selector de vehículo sobre Comparar; lo implementa la capa app.
typedef ComparePickerOpener = Future<void> Function(BuildContext context);

/// Pantalla Comparar: encabezado, hasta 3 espacios y lo que sigue según cuántos haya.
class ComparePage extends StatefulWidget {
  const ComparePage({
    super.key,
    required this.selectorBuilder,
    required this.visuals,
    required this.onOpenPicker,
    this.openPickerOnEntry = false,
  });

  /// Píldora de mercado y año del encabezado; la implementa la capa app.
  final WidgetBuilder selectorBuilder;

  /// Foto y logo de cada vehículo; los implementa la capa app.
  final CompareSlotVisuals visuals;

  /// Selector de vehículo como hoja inferior; lo implementa la capa app.
  final ComparePickerOpener onOpenPicker;

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
    unawaited(widget.onOpenPicker(context));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        NavConfig.footprint +
        MediaQuery.paddingOf(context).bottom +
        ModelGridConfig.listBottomGap;
    // Se lee aquí: el Scaffold quita el teclado del MediaQuery de su cuerpo.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const StatusBarBandSliver(),
              SliverToBoxAdapter(
                child: HeroHeaderWidget(
                  includeTopInset: false,
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
          _ChartButton(keyboardOpen: keyboardOpen),
        ],
      ),
    );
  }
}

/// Botón flotante de la gráfica: aparece con métricas comparables.
class _ChartButton extends StatelessWidget {
  const _ChartButton({required this.keyboardOpen});

  final bool keyboardOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        final slots = state is CompareLoaded && state.selection.canCompare
            ? state.selection.slots
            : const <CompareSlotEntity>[];
        // Sin vehículos que comparar no hace falta leer la tabla.
        if (slots.isEmpty) {
          return CompareChartButtonWidget(
            visible: false,
            keyboardOpen: keyboardOpen,
            onTap: () {},
          );
        }
        return BlocBuilder<CompareTableCubit, CompareTableState>(
          builder: (context, table) {
            final metrics = const CompareChartBuilder().build(
              const CompareTableBuilder().build(
                marketCode: slots.first.marketCode,
                columns: table.detailsOf(slots),
              ),
            );
            return CompareChartButtonWidget(
              visible: metrics.isNotEmpty,
              keyboardOpen: keyboardOpen,
              onTap: () => unawaited(
                showCompareChartSheet(
                  context,
                  metrics: metrics,
                  names: [
                    for (final slot in slots)
                      AppTexts.compareColumnHeaderLabel(
                        slot.brand,
                        slot.modelName,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                _NoticeSlot(
                  notice: notice,
                  subject: current.noticeSubject,
                  other: current.noticeOther,
                  noticeId: current.noticeId,
                ),
                // Alto fijo: el diseño no salta cuando aparece o se va "Limpiar".
                SizedBox(
                  height: CompareConfig.removeTouchSize,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          AppTexts.compareSlotsCountLabel(
                            selection.length,
                            CompareConfig.maxSlots,
                          ),
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const _HelpButton(),
                      const Spacer(),
                      if (!selection.isEmpty)
                        TextButton(
                          onPressed: () =>
                              unawaited(_confirmClear(context, selection)),
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

  // Limpiar pide confirmar; quitar un solo vehículo no.
  Future<void> _confirmClear(
    BuildContext context,
    CompareSelectionEntity selection,
  ) async {
    final cubit = context.read<CompareCubit>();
    final confirmed = await showCompareClearDialog(context, selection.length);
    if (confirmed) await cubit.clear();
  }
}

/// Botón de ícono "¿Cómo funciona?" junto al contador; no abre nada solo.
class _HelpButton extends StatelessWidget {
  const _HelpButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.compareHelpButtonLabel,
      excludeSemantics: true,
      child: IconButton(
        onPressed: () => unawaited(showCompareHelpSheet(context)),
        tooltip: AppTexts.compareHelpButtonLabel,
        constraints: const BoxConstraints(
          minWidth: CompareConfig.removeTouchSize,
          minHeight: CompareConfig.removeTouchSize,
        ),
        icon: const Icon(
          Symbols.help,
          size: CompareConfig.helpButtonIconSize,
          color: AppColors.mutedText,
        ),
      ),
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
            // La banda fija de la barra de estado ya cubre el área segura.
            topInset: 0,
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
  const _NoticeSlot({
    required this.notice,
    required this.subject,
    required this.other,
    required this.noticeId,
  });

  final CompareNotice? notice;
  final String? subject;
  final String? other;
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
              subject: subject,
              other: other,
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
