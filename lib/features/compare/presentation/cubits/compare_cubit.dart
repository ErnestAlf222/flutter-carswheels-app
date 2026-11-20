import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/config/compare_config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/compare_state.dart';

/// Selección del comparador del mercado activo; vive a nivel de app.
class CompareCubit extends Cubit<CompareState> {
  CompareCubit({
    required this.marketSource,
    required this.addToCompare,
    required this.removeFromCompare,
    required this.clearCompare,
    required this.observeSelection,
    required this.updateSlotVersion,
    required this.replaceSlot,
    this.noticeDuration = const Duration(
      milliseconds: CompareConfig.noticeDurationMilliseconds,
    ),
  }) : super(const CompareLoading()) {
    _marketSubscription = marketSource.marketChanges.listen(_watch);
    _watch(marketSource.marketCode);
  }

  final CompareMarketSource marketSource;
  final AddToCompareUseCase addToCompare;
  final RemoveFromCompareUseCase removeFromCompare;
  final ClearCompareUseCase clearCompare;
  final ObserveCompareSelectionUseCase observeSelection;
  final UpdateCompareSlotVersionUseCase updateSlotVersion;
  final ReplaceCompareSlotUseCase replaceSlot;

  /// Cuánto se muestra el mensaje breve.
  final Duration noticeDuration;

  // Recursos cancelables: se reasignan al cambiar de mercado o de mensaje.
  StreamSubscription<String>? _marketSubscription;
  StreamSubscription<CompareSelectionEntity>? _selectionSubscription;
  Timer? _noticeTimer;

  /// Agrega un vehículo y deja un mensaje breve según el resultado.
  ///
  /// [announce] en falso omite el mensaje de "agregado" y el de "lleno": quien
  /// llama decide qué mostrar (por ejemplo, la hoja de reemplazo de Detalle).
  Future<CompareAddResult> add(
    CompareSlotEntity slot, {
    bool announce = true,
  }) async {
    final result = await addToCompare(slot);
    if (isClosed) return result;
    switch (result) {
      case CompareAdded():
        if (announce) {
          _showNotice(
            result.selection,
            CompareNotice.added,
            subject: _nameOf(slot),
          );
        }
      case CompareAlreadyPresent():
        _showNotice(result.selection, CompareNotice.alreadyAdded);
      case CompareFull():
        if (announce) _showNotice(result.selection, CompareNotice.full);
    }
    return result;
  }

  /// Cambia [current] por [replacement] en la misma posición, con su mensaje.
  Future<CompareReplaceResult> replace(
    CompareSlotEntity current,
    CompareSlotEntity replacement,
  ) async {
    final result = await replaceSlot(current, replacement);
    final state = this.state;
    if (isClosed || state is! CompareLoaded) return result;
    if (result == CompareReplaceResult.replaced) {
      // La lista guardada llega después por el flujo; el mensaje no la espera.
      _showNotice(
        CompareSelectionEntity([
          for (final item in state.selection.slots)
            item.identity == current.identity ? replacement : item,
        ]),
        CompareNotice.replaced,
        subject: _nameOf(replacement),
        other: _nameOf(current),
      );
    } else if (result == CompareReplaceResult.alreadyPresent) {
      _showNotice(state.selection, CompareNotice.alreadyAdded);
    }
    return result;
  }

  /// Vacía la selección y deja solo [slot], con su mensaje.
  Future<void> clearAndAdd(CompareSlotEntity slot) async {
    await clearCompare(marketSource.marketCode);
    final result = await addToCompare(slot);
    if (isClosed) return;
    _showNotice(
      result.selection,
      CompareNotice.startedNew,
      subject: _nameOf(slot),
    );
  }

  // Nombre corto para los mensajes: marca y modelo.
  String _nameOf(CompareSlotEntity slot) =>
      AppTexts.compareColumnHeaderLabel(slot.brand, slot.modelName);

  /// Quita un vehículo; la lista se actualiza sola desde lo guardado.
  Future<void> remove(CompareSlotEntity slot) => removeFromCompare(slot);

  /// Cambia la versión de un vehículo; nula vuelve a la predeterminada.
  ///
  /// Si otro espacio ya es exactamente ese, no cambia y deja un mensaje breve.
  Future<CompareVersionUpdateResult> changeVersion(
    CompareSlotEntity slot,
    String? versionKey,
  ) async {
    final result = await updateSlotVersion(slot, versionKey);
    final current = state;
    if (!isClosed &&
        result == CompareVersionUpdateResult.duplicate &&
        current is CompareLoaded) {
      _showNotice(current.selection, CompareNotice.alreadyAdded);
    }
    return result;
  }

  /// Vacía la selección del mercado activo.
  Future<void> clear() => clearCompare(marketSource.marketCode);

  /// Oculta el mensaje breve antes de que venza.
  void dismissNotice() {
    _noticeTimer?.cancel();
    final current = state;
    if (isClosed || current is! CompareLoaded || current.notice == null) return;
    emit(current.copyWith(clearNotice: true));
  }

  // Cambia la lista observada: la del mercado indicado.
  void _watch(String marketCode) {
    unawaited(_selectionSubscription?.cancel());
    _noticeTimer?.cancel();
    emit(const CompareLoading());
    _selectionSubscription = observeSelection(marketCode).listen(
      _onSelection,
      // Sin lectura posible la pantalla sigue con la lista vacía.
      onError: (Object _) => _onSelection(CompareSelectionEntity.empty),
    );
  }

  void _onSelection(CompareSelectionEntity selection) {
    if (isClosed) return;
    final current = state;
    emit(
      current is CompareLoaded
          ? current.copyWith(selection: selection)
          : CompareLoaded(selection: selection),
    );
  }

  void _showNotice(
    CompareSelectionEntity selection,
    CompareNotice notice, {
    String? subject,
    String? other,
  }) {
    final current = state;
    final previousId = current is CompareLoaded ? current.noticeId : 0;
    emit(
      CompareLoaded(
        selection: selection,
        notice: notice,
        noticeSubject: subject,
        noticeOther: other,
        noticeId: previousId + 1,
      ),
    );
    _noticeTimer?.cancel();
    _noticeTimer = Timer(noticeDuration, dismissNotice);
  }

  @override
  Future<void> close() async {
    _noticeTimer?.cancel();
    await _marketSubscription?.cancel();
    await _selectionSubscription?.cancel();
    return super.close();
  }
}
