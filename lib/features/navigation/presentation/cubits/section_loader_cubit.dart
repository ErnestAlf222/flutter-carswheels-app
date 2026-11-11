import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/presentation/cubits/section_loader_state.dart';

/// Muestra un aviso breve al cambiar entre las secciones del menú.
class SectionLoaderCubit extends Cubit<SectionLoaderState> {
  SectionLoaderCubit() : super(const SectionLoaderState(visible: false));

  // Único campo no final: el temporizador que oculta el aviso.
  Timer? _hideTimer;

  /// Muestra el aviso y lo oculta tras el tiempo configurado.
  void onSectionChanged() {
    _hideTimer?.cancel();
    emit(const SectionLoaderState(visible: true));
    _hideTimer = Timer(
      const Duration(
        milliseconds: AnimationConfig.sectionLoaderVisibleMilliseconds,
      ),
      () => emit(const SectionLoaderState(visible: false)),
    );
  }

  @override
  Future<void> close() {
    _hideTimer?.cancel();
    return super.close();
  }
}
