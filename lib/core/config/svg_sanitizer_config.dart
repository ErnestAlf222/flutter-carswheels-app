/// Patrones y marcas que usa el saneado de SVG.
class SvgSanitizerConfig {
  const SvgSanitizerConfig._();

  // Apertura de <switch ...>, conservando sus atributos.
  static final RegExp switchOpenTag = RegExp(r'<switch(?=[\s>/])');
  static final RegExp switchCloseTag = RegExp(r'</switch\s*>');
  static const String groupOpenTag = '<g';
  static const String groupCloseTag = '</g>';

  // Bloque <style> completo y su contenido.
  static final RegExp styleBlock = RegExp(
    r'<style\b[^>]*>(.*?)</style\s*>',
    caseSensitive: false,
    dotAll: true,
  );
  // Comentarios CSS que se descartan antes de leer las reglas.
  static final RegExp cssComment = RegExp(r'/\*.*?\*/', dotAll: true);
  // Regla CSS: selectores { declaraciones }.
  static final RegExp cssRule = RegExp(r'([^{}]+)\{([^{}]*)\}');
  // Selector de clase simple, como .st3.
  static final RegExp simpleClassSelector = RegExp(r'^\.([A-Za-z_][\w-]*)$');
  // Etiqueta de apertura de un elemento, con su nombre y atributos.
  static final RegExp startTag = RegExp(r'<([A-Za-z][\w:.-]*)([^<>]*?)(/?)>');
  static final RegExp classAttribute = RegExp(
    r'''\sclass\s*=\s*(?:"([^"]*)"|'([^']*)')''',
  );
  static final RegExp styleAttribute = RegExp(
    r'''\sstyle\s*=\s*(?:"([^"]*)"|'([^']*)')''',
  );
  static final RegExp whitespaceRun = RegExp(r'\s+');

  static const String selectorSeparator = ',';
  static const String declarationSeparator = ';';
  static const String declarationAssignment = ':';
}
