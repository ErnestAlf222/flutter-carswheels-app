import 'package:cars_wheels_app/core/config/config.dart';

/// Adapta un SVG a lo que flutter_svg sabe dibujar; no lanza errores.
class SvgSanitizer {
  const SvgSanitizer();

  /// Cambia `<switch>` por `<g>` y pasa las clases de `<style>` a atributos style.
  String sanitize(String svg) {
    if (svg.isEmpty) return svg;
    final withoutSwitch = _replaceSwitch(svg);
    return _inlineClassStyles(withoutSwitch);
  }

  /// Cuenta los selectores de `<style>` que no son una clase simple.
  int countUnsupportedSelectors(String svg) => _readRules(svg)
      .expand((rule) => _splitSelectors(rule.selectors))
      .where(
        (selector) =>
            !SvgSanitizerConfig.simpleClassSelector.hasMatch(selector),
      )
      .length;

  String _replaceSwitch(String svg) => svg
      .replaceAll(
        SvgSanitizerConfig.switchOpenTag,
        SvgSanitizerConfig.groupOpenTag,
      )
      .replaceAll(
        SvgSanitizerConfig.switchCloseTag,
        SvgSanitizerConfig.groupCloseTag,
      );

  String _inlineClassStyles(String svg) {
    if (!SvgSanitizerConfig.styleBlock.hasMatch(svg)) return svg;
    final classStyles = _classDeclarations(svg);
    final withoutStyle = svg.replaceAll(SvgSanitizerConfig.styleBlock, '');
    if (classStyles.isEmpty) return withoutStyle;
    return withoutStyle.replaceAllMapped(
      SvgSanitizerConfig.startTag,
      (match) => _applyClasses(match, classStyles),
    );
  }

  // Declaraciones por nombre de clase; una regla posterior pisa a la anterior.
  Map<String, Map<String, String>> _classDeclarations(String svg) {
    final result = <String, Map<String, String>>{};
    for (final rule in _readRules(svg)) {
      final declarations = _parseDeclarations(rule.body);
      for (final selector in _splitSelectors(rule.selectors)) {
        final className = SvgSanitizerConfig.simpleClassSelector
            .firstMatch(selector)
            ?.group(1);
        if (className == null) continue;
        result
            .putIfAbsent(className, () => <String, String>{})
            .addAll(declarations);
      }
    }
    return result;
  }

  Iterable<({String selectors, String body})> _readRules(String svg) sync* {
    for (final block in SvgSanitizerConfig.styleBlock.allMatches(svg)) {
      final css = (block.group(1) ?? '').replaceAll(
        SvgSanitizerConfig.cssComment,
        '',
      );
      for (final rule in SvgSanitizerConfig.cssRule.allMatches(css)) {
        yield (selectors: rule.group(1) ?? '', body: rule.group(2) ?? '');
      }
    }
  }

  List<String> _splitSelectors(String selectors) => selectors
      .split(SvgSanitizerConfig.selectorSeparator)
      .map((selector) => selector.trim())
      .where((selector) => selector.isNotEmpty)
      .toList();

  Map<String, String> _parseDeclarations(String body) {
    final result = <String, String>{};
    for (final part in body.split(SvgSanitizerConfig.declarationSeparator)) {
      final index = part.indexOf(SvgSanitizerConfig.declarationAssignment);
      if (index <= 0) continue;
      final name = part.substring(0, index).trim();
      final value = part.substring(index + 1).trim();
      if (name.isEmpty || value.isEmpty) continue;
      result[name] = value;
    }
    return result;
  }

  String _applyClasses(
    Match tag,
    Map<String, Map<String, String>> classStyles,
  ) {
    final attributes = tag.group(2) ?? '';
    final classMatch = SvgSanitizerConfig.classAttribute.firstMatch(attributes);
    if (classMatch == null) return tag.group(0)!;
    final classNames = (classMatch.group(1) ?? classMatch.group(2) ?? '')
        .trim()
        .split(SvgSanitizerConfig.whitespaceRun);
    final merged = <String, String>{};
    for (final className in classNames) {
      merged.addAll(classStyles[className] ?? const <String, String>{});
    }
    if (merged.isEmpty) return tag.group(0)!;
    final styleMatch = SvgSanitizerConfig.styleAttribute.firstMatch(attributes);
    if (styleMatch != null) {
      // Lo que ya tenía el elemento en style tiene prioridad.
      merged.addAll(
        _parseDeclarations(styleMatch.group(1) ?? styleMatch.group(2) ?? ''),
      );
    }
    final cleanAttributes = attributes.replaceAll(
      SvgSanitizerConfig.styleAttribute,
      '',
    );
    final style = merged.entries
        .map(
          (entry) =>
              '${entry.key}${SvgSanitizerConfig.declarationAssignment}${entry.value}',
        )
        .join(SvgSanitizerConfig.declarationSeparator);
    return '<${tag.group(1)}$cleanAttributes style="$style"${tag.group(3)}>';
  }
}
