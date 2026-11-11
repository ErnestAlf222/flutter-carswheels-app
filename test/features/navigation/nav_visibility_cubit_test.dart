import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hidden = NavVisibilityState(visible: false);
  const shown = NavVisibilityState(visible: true);

  test('inicia visible', () {
    expect(NavVisibilityCubit().state, shown);
  });

  blocTest<NavVisibilityCubit, NavVisibilityState>(
    'delta positiva sobre el umbral lo oculta',
    build: NavVisibilityCubit.new,
    act: (cubit) => cubit.onScroll(NavConfig.scrollDeltaThreshold + 1),
    expect: () => [hidden],
  );

  blocTest<NavVisibilityCubit, NavVisibilityState>(
    'delta negativa lo muestra de inmediato',
    build: NavVisibilityCubit.new,
    act: (cubit) => cubit
      ..onScroll(NavConfig.scrollDeltaThreshold + 1)
      ..onScroll(-1),
    expect: () => [hidden, shown],
  );

  blocTest<NavVisibilityCubit, NavVisibilityState>(
    'vuelve a mostrarse tras la espera',
    build: NavVisibilityCubit.new,
    act: (cubit) => cubit.onScroll(NavConfig.scrollDeltaThreshold + 1),
    wait: const Duration(milliseconds: NavConfig.reappearDelayMilliseconds),
    expect: () => [hidden, shown],
  );
}
