import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const visibleTime = Duration(
    milliseconds: AnimationConfig.sectionLoaderVisibleMilliseconds,
  );

  test('empieza oculto', () async {
    final cubit = SectionLoaderCubit();
    expect(cubit.state.visible, isFalse);
    await cubit.close();
  });

  blocTest<SectionLoaderCubit, SectionLoaderState>(
    'onSectionChanged muestra y oculta tras el tiempo configurado',
    build: SectionLoaderCubit.new,
    act: (cubit) => cubit.onSectionChanged(),
    wait: visibleTime + const Duration(milliseconds: 50),
    expect: () => const [
      SectionLoaderState(visible: true),
      SectionLoaderState(visible: false),
    ],
  );

  blocTest<SectionLoaderCubit, SectionLoaderState>(
    'sigue visible antes de cumplirse el tiempo',
    build: SectionLoaderCubit.new,
    act: (cubit) => cubit.onSectionChanged(),
    wait: visibleTime ~/ 2,
    expect: () => const [SectionLoaderState(visible: true)],
  );

  blocTest<SectionLoaderCubit, SectionLoaderState>(
    'un cambio nuevo reinicia el temporizador',
    build: SectionLoaderCubit.new,
    act: (cubit) async {
      cubit.onSectionChanged();
      await Future<void>.delayed(visibleTime * 0.75);
      cubit.onSectionChanged();
      await Future<void>.delayed(visibleTime * 0.75);
      expect(cubit.state.visible, isTrue);
    },
    wait: visibleTime,
    verify: (cubit) => expect(cubit.state.visible, isFalse),
  );

  test('cerrar el cubit cancela el temporizador', () async {
    final cubit = SectionLoaderCubit()..onSectionChanged();
    await cubit.close();
    await Future<void>.delayed(visibleTime + const Duration(milliseconds: 50));
    expect(cubit.isClosed, isTrue);
  });
}
