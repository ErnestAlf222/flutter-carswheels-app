import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/brand_logos/presentation/cubits/logo_precache_state.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/services/services.dart';

/// Precarga logos sin repetir una misma URL durante la sesión.
class LogoPrecacheCubit extends Cubit<LogoPrecacheState> {
  LogoPrecacheCubit({this.service = const LogoPrecacheService()})
    : super(const LogoPrecacheState());

  final LogoPrecacheService service;

  /// Precarga las URLs que aún no se pidieron.
  void precache(BuildContext context, Iterable<String> urls) {
    final pending = urls.toSet().difference(state.requestedUrls);
    if (pending.isEmpty) return;
    emit(
      LogoPrecacheState(requestedUrls: {...state.requestedUrls, ...pending}),
    );
    for (final url in pending) {
      service.precache(context, url);
    }
  }
}
