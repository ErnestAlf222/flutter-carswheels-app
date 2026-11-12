import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

void main() {
  late _MockBrandLogosCubit cubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    cubit = _MockBrandLogosCubit();
    when(() => cubit.state).thenReturn(const BrandLogosInitial());
  });

  Widget host() => MaterialApp(
    home: BlocProvider<BrandLogosCubit>.value(
      value: cubit,
      child: const Scaffold(body: BrandLogoWidget(brandName: 'audi', size: 42)),
    ),
  );

  testWidgets('sin URL muestra el monograma con la inicial', (tester) async {
    when(() => cubit.urlFor('audi')).thenReturn(null);
    await tester.pumpWidget(host());
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byType(CachedNetworkImage), findsNothing);
    final text = tester.widget<Text>(find.text('A'));
    expect(text.style!.color, AppColors.tintText);
  });

  testWidgets('con URL .svg construye SvgPicture', (tester) async {
    when(
      () => cubit.urlFor('audi'),
    ).thenReturn('${LogosConfig.logosBaseUrl}audi${LogosConfig.svgExtension}');
    await tester.pumpWidget(host());
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('con URL .png construye CachedNetworkImage', (tester) async {
    when(() => cubit.urlFor('audi'))
        .thenReturn('${LogosConfig.logosBaseUrl}audi.png');
    await tester.pumpWidget(host());
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('el cargador SVG envía el User-Agent configurado', (
    tester,
  ) async {
    when(
      () => cubit.urlFor('audi'),
    ).thenReturn('${LogosConfig.logosBaseUrl}audi${LogosConfig.svgExtension}');
    await tester.pumpWidget(host());
    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    final loader = picture.bytesLoader as SanitizedSvgNetworkLoader;
    expect(loader.headers, LogosConfig.requestHeaders);
    expect(
      loader.headers![HttpHeaders.userAgentHeader],
      UserAgentsConfig.logosUserAgent,
    );
  });

  testWidgets('el cargador PNG envía el User-Agent configurado', (
    tester,
  ) async {
    when(() => cubit.urlFor('audi'))
        .thenReturn('${LogosConfig.logosBaseUrl}audi.png');
    await tester.pumpWidget(host());
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.httpHeaders, LogosConfig.requestHeaders);
    expect(
      image.httpHeaders![HttpHeaders.userAgentHeader],
      UserAgentsConfig.logosUserAgent,
    );
  });
}
