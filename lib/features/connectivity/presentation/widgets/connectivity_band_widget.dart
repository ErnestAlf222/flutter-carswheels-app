import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/domain/domain.dart';
import 'package:cars_wheels_app/features/connectivity/presentation/cubits/cubits.dart';

/// Banda delgada de tinta con el estado de la conexión; sin red no hay nada que ocultar.
///
/// Sin conexión dice "mostrando lo guardado"; al volver se transforma un momento
/// en "Conexión restablecida" y se retira. No bloquea ni cubre la pantalla.
class ConnectivityBandWidget extends StatefulWidget {
  const ConnectivityBandWidget({
    super.key,
    this.offlineLabel = AppTexts.offlineBandLabel,
  });

  /// Texto sin conexión; Favoritos usa uno que dice que sus datos están guardados.
  final String offlineLabel;

  @override
  State<ConnectivityBandWidget> createState() => _ConnectivityBandWidgetState();
}

class _ConnectivityBandWidgetState extends State<ConnectivityBandWidget> {
  @override
  void initState() {
    super.initState();
    // Al mostrarse una pantalla se comprueba la conexión (con tope de frecuencia).
    unawaited(ConnectivityScope.maybeOf(context)?.verify());
  }

  @override
  Widget build(BuildContext context) {
    final offlineLabel = widget.offlineLabel;
    final cubit = ConnectivityScope.maybeOf(context);
    if (cubit == null) return const SizedBox.shrink();
    final still = MediaQuery.of(context).disableAnimations;
    const duration = Duration(
      milliseconds: ConnectivityConfig.bandAnimationMilliseconds,
    );
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      bloc: cubit,
      buildWhen: (previous, current) => previous.phase != current.phase,
      builder: (context, state) {
        final content = switch (state.phase) {
          ConnectionPhase.online => const SizedBox(
            key: ValueKey(ConnectionPhase.online),
            width: double.infinity,
          ),
          ConnectionPhase.offline => _Band(
            key: const ValueKey(ConnectionPhase.offline),
            icon: Symbols.cloud_off,
            label: offlineLabel,
          ),
          ConnectionPhase.restored => const _Band(
            key: ValueKey(ConnectionPhase.restored),
            icon: Symbols.check_circle,
            label: AppTexts.onlineRestoredLabel,
          ),
        };
        // Con disableAnimations el cambio es inmediato, sin transiciones.
        if (still) return content;
        return AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(duration: duration, child: content),
        );
      },
    );
  }
}

/// Banda como sliver, para ir justo debajo del encabezado de cada pantalla.
class ConnectivityBandSliver extends StatelessWidget {
  const ConnectivityBandSliver({
    super.key,
    this.offlineLabel = AppTexts.offlineBandLabel,
  });

  final String offlineLabel;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: ConnectivityBandWidget(offlineLabel: offlineLabel),
  );
}

/// Acceso al cubit de conexión sin exigirlo: una pantalla sin él no muestra banda.
class ConnectivityScope {
  const ConnectivityScope._();

  static ConnectivityCubit? maybeOf(BuildContext context) {
    try {
      return context.read<ConnectivityCubit>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// Verdadero si hay un cubit y la conexión está caída; no escucha cambios.
  static bool isOfflineNow(BuildContext context) =>
      maybeOf(context)?.state.isOffline ?? false;
}

class _Band extends StatelessWidget {
  const _Band({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: ColoredBox(
        color: AppColors.ink,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
              vertical: ConnectivityConfig.bandVerticalPadding,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: ConnectivityConfig.bandIconSize,
                  color: AppColors.accent,
                ),
                const SizedBox(width: ConnectivityConfig.bandIconGap),
                Expanded(
                  child: Text(label, style: AppTextStyles.onDarkCaption),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
