import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/cubits.dart';

/// Aviso de lo que no está disponible sin conexión (calificaciones y retiros).
///
/// Solo aparece sin red y cuando esas consultas fallaron; al volver la conexión
/// Detalle las pide solo y el aviso desaparece.
class DetailOfflineNoticeWidget extends StatelessWidget {
  const DetailOfflineNoticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = ConnectivityScope.maybeOf(context);
    if (connectivity == null) return const SizedBox.shrink();
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      bloc: connectivity,
      buildWhen: (previous, current) => previous.isOffline != current.isOffline,
      builder: (context, connection) {
        if (!connection.isOffline) return const SizedBox.shrink();
        return BlocBuilder<DetailSafetyCubit, DetailSafetyState>(
          buildWhen: (previous, current) =>
              _missing(previous) != _missing(current),
          builder: (context, safety) =>
              _missing(safety) ? const _Notice() : const SizedBox.shrink(),
        );
      },
    );
  }

  // Alguna de las dos consultas de seguridad no llegó.
  static bool _missing(DetailSafetyState state) =>
      state.ratings is SafetyFailed || state.recalls is SafetyFailed;
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailInfoSideMargin,
        AppSpacing.s,
        UiConfig.detailInfoSideMargin,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Symbols.cloud_off,
            size: ConnectivityConfig.bandIconSize,
            color: AppColors.mutedText,
          ),
          const SizedBox(width: ConnectivityConfig.bandIconGap),
          Expanded(
            child: Text(
              AppTexts.offlineDetailNotice,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
