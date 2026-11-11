import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingService extends LogoPrecacheService {
  _RecordingService();

  final List<String> urls = [];

  @override
  Future<void> precache(BuildContext context, String url) async {
    urls.add(url);
  }
}

Future<BuildContext> _context(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    Builder(
      builder: (builderContext) {
        context = builderContext;
        return const SizedBox();
      },
    ),
  );
  return context;
}

void main() {
  testWidgets('precarga cada URL una sola vez en la sesión', (tester) async {
    final service = _RecordingService();
    final cubit = LogoPrecacheCubit(service: service);
    final context = await _context(tester);
    cubit.precache(context, ['a.png', 'b.svg']);
    cubit.precache(context, ['a.png', 'c.png', 'b.svg']);
    cubit.precache(context, ['a.png']);
    expect(service.urls, ['a.png', 'b.svg', 'c.png']);
    expect(cubit.state.requestedUrls, {'a.png', 'b.svg', 'c.png'});
    await cubit.close();
  });

  testWidgets('una lista vacía no emite', (tester) async {
    final cubit = LogoPrecacheCubit(service: _RecordingService());
    final context = await _context(tester);
    cubit.precache(context, const []);
    expect(cubit.state, const LogoPrecacheState());
    await cubit.close();
  });
}
