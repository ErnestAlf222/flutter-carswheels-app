import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/presentation/cubits/cubits.dart';

/// Muestra el mensaje breve de favoritos sobre cualquier pantalla.
///
/// Va sobre el navegador, a [bottomInset] del borde inferior, y lleva el
/// botón "Deshacer" cuando el mensaje es de un favorito quitado desde Favoritos.
class FavoritesMessageHost extends StatelessWidget {
  const FavoritesMessageHost({
    super.key,
    required this.child,
    required this.bottomInset,
  });

  final Widget child;

  /// Distancia al borde inferior; deja libre la barra de navegación.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return Stack(
      children: [
        child,
        Positioned(
          left: UiConfig.pageHorizontalPadding,
          right: UiConfig.pageHorizontalPadding,
          bottom: bottomInset + MediaQuery.paddingOf(context).bottom,
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            buildWhen: (previous, current) =>
                _idOf(previous) != _idOf(current) ||
                _messageOf(previous) != _messageOf(current),
            builder: (context, state) {
              final loaded = state is FavoritesLoaded ? state : null;
              final kind = loaded?.message;
              return AnimatedSwitcher(
                duration: still
                    ? Duration.zero
                    : const Duration(
                        milliseconds: FavoritesConfig.messageEnterMilliseconds,
                      ),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, FavoritesConfig.messageOffset),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: loaded == null || kind == null
                    ? const SizedBox.shrink(key: ValueKey('none'))
                    : _Message(
                        key: ValueKey(loaded.messageId),
                        kind: kind,
                        subject: loaded.messageSubject,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  static int _idOf(FavoritesState state) =>
      state is FavoritesLoaded ? state.messageId : -1;

  static FavoriteMessageKind? _messageOf(FavoritesState state) =>
      state is FavoritesLoaded ? state.message : null;
}

/// Píldora neutra con el texto y, si aplica, la acción de deshacer.
class _Message extends StatelessWidget {
  const _Message({super.key, required this.kind, required this.subject});

  final FavoriteMessageKind kind;
  final String? subject;

  @override
  Widget build(BuildContext context) {
    final text = switch (kind) {
      FavoriteMessageKind.saved => AppTexts.favoriteSavedMessage,
      FavoriteMessageKind.removed => AppTexts.favoriteRemovedMessage,
      FavoriteMessageKind.removedWithUndo =>
        AppTexts.favoriteRemovedNamedMessage(subject ?? ''),
    };
    final undoable = kind == FavoriteMessageKind.removedWithUndo;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.only(
            left: FavoritesConfig.messageHorizontalPadding,
            right: undoable
                ? AppSpacing.xs
                : FavoritesConfig.messageHorizontalPadding,
            top: FavoritesConfig.messageVerticalPadding,
            bottom: FavoritesConfig.messageVerticalPadding,
          ),
          child: Row(
            children: [
              const Icon(
                Symbols.favorite,
                size: FavoritesConfig.messageIconSize,
                color: AppColors.ink,
              ),
              const SizedBox(width: FavoritesConfig.messageIconGap),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: AppColors.ink),
                ),
              ),
              if (undoable)
                TextButton(
                  onPressed: () => context.read<FavoritesCubit>().undo(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    minimumSize: const Size(
                      0,
                      FavoritesConfig.messageActionTouchHeight,
                    ),
                  ),
                  child: Text(
                    AppTexts.favoriteUndoLabel,
                    style: AppTextStyles.bodyStrong,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
