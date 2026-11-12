import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sanitizer = SvgSanitizer();

  group('switch', () {
    test('cambia switch por g conservando atributos', () {
      const input =
          '<switch transform="translate(-251.52 -252.793)scale(10.18839)"><g><path fill="#001e50" d="M75 120.4z"/></g></switch>';
      expect(
        sanitizer.sanitize(input),
        '<g transform="translate(-251.52 -252.793)scale(10.18839)"><g><path fill="#001e50" d="M75 120.4z"/></g></g>',
      );
    });

    test('no confunde otras etiquetas que empiezan con switch', () {
      const input = '<switcher a="1"></switcher>';
      expect(sanitizer.sanitize(input), input);
    });
  });

  group('style con clases', () {
    const styled =
        '<svg><style>.st3{fill:#fff}.st5{fill:#565f64}.st7{fill:#a4aaae;fill-opacity:.6}</style>'
        '<path class="st3" d="M0 0h1z"/><path class="st5" d="M1 1h1z"/><path class="st7" d="M2 2h1z"/></svg>';

    test('pasa cada clase a style y elimina el bloque style', () {
      final result = sanitizer.sanitize(styled);
      expect(result, isNot(contains('<style')));
      expect(
        result,
        contains('<path class="st3" d="M0 0h1z" style="fill:#fff"/>'),
      );
      expect(result, contains('style="fill:#565f64"'));
      expect(result, contains('style="fill:#a4aaae;fill-opacity:.6"'));
    });

    test('regla de McLaren con varias declaraciones', () {
      const input =
          '<svg><style>.st64{fill-rule:evenodd;clip-rule:evenodd;fill:#231f20;stroke:#231f20;stroke-width:.216;stroke-miterlimit:22.9256}</style><path class="st64" d="M0 0z"/></svg>';
      expect(
        sanitizer.sanitize(input),
        contains(
          'style="fill-rule:evenodd;clip-rule:evenodd;fill:#231f20;stroke:#231f20;stroke-width:.216;stroke-miterlimit:22.9256"',
        ),
      );
    });

    test('regla de Land Rover', () {
      const input =
          '<svg><style>.st177{fill:#e5e6e7}</style><path class="st177" d="M0 0z"/></svg>';
      expect(sanitizer.sanitize(input), contains('style="fill:#e5e6e7"'));
    });

    test('lista de selectores .a,.b aplica a ambas clases', () {
      const input =
          '<svg><style>.a,.b{fill:#111}</style><path class="a" d="M0 0z"/><path class="b" d="M1 1z"/></svg>';
      final result = sanitizer.sanitize(input);
      expect('style="fill:#111"'.allMatches(result).length, 2);
    });

    test('dos clases en el mismo elemento fusionan sus declaraciones', () {
      const input =
          '<svg><style>.st3{fill:#fff}.st5{stroke:#000}</style><path class="st3 st5" d="M0 0z"/></svg>';
      expect(
        sanitizer.sanitize(input),
        contains('style="fill:#fff;stroke:#000"'),
      );
    });

    test('el style que ya tiene el elemento tiene prioridad', () {
      const input =
          '<svg><style>.st3{fill:#fff;opacity:1}</style><path class="st3" style="opacity:.5" d="M0 0z"/></svg>';
      final result = sanitizer.sanitize(input);
      expect(result, contains('style="fill:#fff;opacity:.5"'));
      expect('style='.allMatches(result).length, 1);
    });

    test('cuenta y no trata selectores que no son clase simple', () {
      const input =
          '<svg><style>path{fill:red}.a .b{fill:blue}.ok{fill:#000}</style><path class="ok" d="M0 0z"/></svg>';
      expect(sanitizer.countUnsupportedSelectors(input), 2);
      final result = sanitizer.sanitize(input);
      expect(result, contains('style="fill:#000"'));
      expect(result, isNot(contains('blue')));
    });

    test('clase sin regla deja el elemento igual', () {
      const input =
          '<svg><style>.a{fill:#000}</style><path class="zz" d="M0 0z"/></svg>';
      expect(
        sanitizer.sanitize(input),
        contains('<path class="zz" d="M0 0z"/>'),
      );
    });
  });

  group('sin cambios', () {
    test('un SVG sin switch ni style se devuelve igual', () {
      const input = '<svg><path fill="#000" d="M0 0z"/></svg>';
      expect(sanitizer.sanitize(input), input);
      expect(sanitizer.countUnsupportedSelectors(input), 0);
    });

    test('cadena vacía se devuelve igual', () {
      expect(sanitizer.sanitize(''), '');
    });

    test('texto que no es SVG no lanza errores', () {
      expect(sanitizer.sanitize('<style>{{{'), '<style>{{{');
    });
  });
}
