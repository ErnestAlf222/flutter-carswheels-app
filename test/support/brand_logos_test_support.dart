import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:mocktail/mocktail.dart';

/// Cubit de logos falso para pruebas de widgets.
class MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

/// Prepara el cubit falso; solo las marcas dadas tienen logo.
MockBrandLogosCubit buildMockBrandLogosCubit({
  Map<String, String> urls = const {},
}) {
  final cubit = MockBrandLogosCubit();
  when(() => cubit.state).thenReturn(const BrandLogosInitial());
  when(() => cubit.urlFor(any())).thenAnswer(
    (invocation) => urls[invocation.positionalArguments.first as String],
  );
  return cubit;
}
