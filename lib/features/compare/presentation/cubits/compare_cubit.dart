import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/config/compare_config.dart';
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

  /// Cuánto se muestra el mensaje breve.
  final Duration noticeDuration;

  // Recursos cancelables: se reasignan al cambiar de mercado o de mensaje.
  StreamSubscription<String>? _marketSubscription;
  StreamSubscription<CompareSelectionEntity>? _selectionSubscription;
  Timer? _noticeTimer;

  /// Agrega un vehículo; "ya está" y "lleno" dejan un mensaje breve.
  Future<CompareAddResult> add(CompareSlotEntity slot) async {
    final result = await addToCompare(slot);
    if (isClosed) return result;
    switch (result) {
      case CompareAdded():
        break;
      case CompareAlreadyPresent():
        _showNotice(result.selection, CompareNotice.alreadyAdded);
      case CompareFull():
        _showNotice(result.selection, CompareNotice.full);
    }
    return result;
  }

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

  void _showNotice(CompareSelectionEntity selection, CompareNotice notice) {
    final current = state;
    final previousId = current is CompareLoaded ? current.noticeId : 0;
    emit(
      CompareLoaded(
        selection: selection,
        notice: notice,
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
