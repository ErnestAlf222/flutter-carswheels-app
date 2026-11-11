import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/presentation/cubits/nav_visibility_state.dart';

/// Oculta el menú al bajar y lo muestra al subir o tras una pausa.
class NavVisibilityCubit extends Cubit<NavVisibilityState> {
  NavVisibilityCubit() : super(const NavVisibilityState(visible: true));

  Timer? _reappearTimer;

  void onScroll(double delta) {
    if (delta > NavConfig.scrollDeltaThreshold) {
      emit(const NavVisibilityState(visible: false));
      _reappearTimer?.cancel();
      _reappearTimer = Timer(
        const Duration(milliseconds: NavConfig.reappearDelayMilliseconds),
        () => emit(const NavVisibilityState(visible: true)),
      );
    } else if (delta < 0) {
      _reappearTimer?.cancel();
      emit(const NavVisibilityState(visible: true));
    }
  }

  @override
  Future<void> close() {
    _reappearTimer?.cancel();
    return super.close();
  }
}
