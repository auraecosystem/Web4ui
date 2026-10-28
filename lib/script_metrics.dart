/// Lightweight, deterministic statistics for source shown in the Web4ui editor.
///
/// This helper does not execute or parse the supplied script. It is safe to use
/// for editor feedback before handing source to a configured analyzer.
class ScriptMetrics {
  const ScriptMetrics({
    required this.characterCount,
    required this.lineCount,
    required this.nonEmptyLineCount,
    required this.todoCount,
    required this.fixmeCount,
  });

  final int characterCount;
  final int lineCount;
  final int nonEmptyLineCount;
  final int todoCount;
  final int fixmeCount;

  factory ScriptMetrics.fromSource(String source) {
    final lines = source.split('\n');
    return ScriptMetrics(
      characterCount: source.length,
      lineCount: source.isEmpty ? 0 : lines.length,
      nonEmptyLineCount: lines.where((line) => line.trim().isNotEmpty).length,
      todoCount: RegExp(r'\bTODO\b', caseSensitive: false)
          .allMatches(source)
          .length,
      fixmeCount: RegExp(r'\bFIXME\b', caseSensitive: false)
          .allMatches(source)
          .length,
    );
  }

  bool get hasActionItems => todoCount > 0 || fixmeCount > 0;
}
