import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';
import 'package:cars_wheels_app/features/favorites/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorite_burst_widget.dart';

/// Corazón de un modelo: círculo blanco con contorno, o amarillo con corazón lleno.
///
/// Consulta el estado en [FavoritesCubit] y lo alterna al tocarlo; el toque no
/// llega a la tarjeta que lo contiene.
class FavoriteHeartButtonWidget extends StatelessWidget {
  const FavoriteHeartButtonWidget({
    super.key,
    required this.identity,
    this.initialSnapshot = FavoriteSnapshotEntity.empty,
    this.onTap,
    this.touchSize = FavoritesConfig.heartTouchSize,
    this.circleSize = FavoritesConfig.heartCircleSize,
    this.iconSize = FavoritesConfig.heartIconSize,
    this.elevated = false,
  });

  final FavoriteIdentity identity;

  /// Lo que la tarjeta ya sabe del modelo (por ejemplo sus variantes).
  final FavoriteSnapshotEntity initialSnapshot;

  /// Reemplaza el alternar por defecto (Favoritos quita con "Deshacer").
  final VoidCallback? onTap;
  final double touchSize;
  final double circleSize;
  final double iconSize;

  /// Con sombra suave, para la barra inferior de Detalle.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) =>
          state is FavoritesLoaded && state.isFavorite(identity.key),
      builder: (context, active) => _Heart(
        active: active,
        semanticLabel: active
            ? AppTexts.favoriteRemoveSemanticLabel(identity.modelName)
            : AppTexts.favoriteAddSemanticLabel(identity.modelName),
        touchSize: touchSize,
        circleSize: circleSize,
        iconSize: iconSize,
        elevated: elevated,
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          final custom = onTap;
          if (custom != null) {
            custom();
            return;
          }
          unawaited(
            context.read<FavoritesCubit>().toggle(
              identity,
              initialSnapshot: initialSnapshot,
            ),
          );
        },
      ),
    );
  }
}

class _Heart extends StatefulWidget {
  const _Heart({
    required this.active,
    required this.semanticLabel,
    required this.touchSize,
    required this.circleSize,
    required this.iconSize,
    required this.elevated,
    required this.onTap,
  });

  final bool active;
  final String semanticLabel;
  final double touchSize;
  final double circleSize;
  final double iconSize;
  final bool elevated;
  final VoidCallback onTap;

  @override
  State<_Heart> createState() => _HeartState();
}

class _HeartState extends State<_Heart> with SingleTickerProviderStateMixin {
  // Único estado: el controlador de la animación de escala al activar.
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: FavoritesConfig.heartPopMilliseconds,
    ),
  );

  @override
  void didUpdateWidget(_Heart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final still = MediaQuery.of(context).disableAnimations;
    if (!oldWidget.active && widget.active && !still) {
      _pop.forward(from: 0);
      // Solo al activar; la capa se inserta después de construir, no durante.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showFavoriteBurst(context);
      });
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final circle = DecoratedBox(
      decoration: BoxDecoration(
        color: active ? AppColors.accent : AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: widget.elevated || !active ? AppShadows.soft : null,
      ),
      child: SizedBox(
        width: widget.circleSize,
        height: widget.circleSize,
        child: Icon(
          Symbols.favorite,
          fill: active ? 1.0 : 0.0,
          size: widget.iconSize,
          color: AppColors.ink,
        ),
      ),
    );
    return Semantics(
      container: true,
      button: true,
      toggled: active,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: widget.touchSize,
        height: widget.touchSize,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedBuilder(
                animation: _pop,
                builder: (context, child) => Transform.scale(
                  // Sube y baja una sola vez: 1 → 1 + pico → 1.
                  scale:
                      1 +
                      FavoritesConfig.heartPopPeak *
                          math.sin(math.pi * _pop.value),
                  child: child,
                ),
                child: circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
