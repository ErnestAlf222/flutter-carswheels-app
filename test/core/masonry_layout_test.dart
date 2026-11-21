import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/favorites_test_support.dart';

void main() {
  group('MasonryLayout', () {
    test('reparte cada tarjeta en la columna más corta', () {
      final result = MasonryLayout.place(
        heights: [100, 60, 60, 60],
        columns: 2,
        spacing: 10,
      );
      expect([for (final slot in result.slots) slot.column], [0, 1, 1, 0]);
      expect([for (final slot in result.slots) slot.top], [0, 0, 70, 110]);
      expect(result.height, 170);
    });

    test('con empate gana la primera columna', () {
      final result = MasonryLayout.place(
        heights: [50, 50, 50],
        columns: 2,
        spacing: 8,
      );
      expect([for (final slot in result.slots) slot.column], [0, 1, 0]);
    });

    test('sin tarjetas no hay alto', () {
      final result = MasonryLayout.place(heights: [], columns: 2, spacing: 8);
      expect(result.slots, isEmpty);
      expect(result.height, 0);
    });
  });

  group('FavoriteSelectionPolicy', () {
    final us = testFavorite(model: 'Camry');
    final us2 = testFavorite(model: 'Corolla');
    final mx = testFavorite(model: 'Versa', marketCode: 'mx');

    test('el primero elegido fija el mercado y bloquea el otro', () {
      const policy = FavoriteSelectionPolicy();
      expect(policy.lockedMarket([]), isNull);
      expect(policy.lockedMarket([us]), 'us');
      expect(policy.blockFor(us, []), FavoriteSelectionBlock.none);
      expect(policy.blockFor(mx, [us]), FavoriteSelectionBlock.otherMarket);
      expect(policy.blockFor(us2, [us]), FavoriteSelectionBlock.none);
    });

    test('la capacidad restante limita cuántos se eligen', () {
      const policy = FavoriteSelectionPolicy(remainingByMarket: {'us': 1});
      expect(policy.blockFor(us, []), FavoriteSelectionBlock.none);
      expect(policy.blockFor(us2, [us]), FavoriteSelectionBlock.limitReached);
    });

    test('sin capacidad ni el primero se puede elegir', () {
      const policy = FavoriteSelectionPolicy(remainingByMarket: {'us': 0});
      expect(policy.blockFor(us, []), FavoriteSelectionBlock.noCapacity);
      // El otro mercado no se ve afectado.
      expect(policy.blockFor(mx, []), FavoriteSelectionBlock.none);
    });

    test('sin dato de capacidad cabe el máximo de la comparación', () {
      const policy = FavoriteSelectionPolicy();
      expect(policy.remaining('us'), CompareConfig.maxSlots);
    });

    test('con uno elegido ya se puede comparar; la comparación pide dos', () {
      const policy = FavoriteSelectionPolicy();
      expect(policy.canCompare([]), isFalse);
      expect(policy.canCompare([us]), isTrue);
      expect(policy.needsMoreCars([us]), isTrue);
      expect(policy.needsMoreCars([us, us2]), isFalse);
      // Con uno ya agregado, elegir uno completa el mínimo.
      const withOne = FavoriteSelectionPolicy(remainingByMarket: {'us': 2});
      expect(withOne.needsMoreCars([us]), isFalse);
    });
  });
}
