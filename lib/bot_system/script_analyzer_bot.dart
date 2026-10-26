import 'bot_plugin.dart';

/// Lightweight text-based script checks. This is a heuristic, not a Dart parser.
class ScriptAnalyzerBot implements BotPlugin {
  @override
  String get id => 'script-analyzer';

  @override
  String get name => 'Script Analyzer';

  @override
  String get description =>
      'Counts lines and comment markers, detects async/await and TODO/FIXME.';

  @override
  Future<String> run(String input) async {
    final lineCount = input.isEmpty ? 0 : '\n'.allMatches(input).length + 1;
    final commentLineCount = RegExp(r'^\s*//', multiLine: true)
        .allMatches(input)
        .length;
    final blockCommentCount =
        RegExp(r'/\*[\s\S]*?\*/').allMatches(input).length;
    final todoCount =
        RegExp(r'\b(?:TODO|FIXME)\b', caseSensitive: false)
            .allMatches(input)
            .length;
    final usesAsync = RegExp(r'\basync\b').hasMatch(input);
    final usesAwait = RegExp(r'\bawait\b').hasMatch(input);

    return [
      'Script Analysis Report',
      'Lines: $lineCount',
      'Line comments: $commentLineCount',
      'Block comments: $blockCommentCount',
      'TODO/FIXME markers: $todoCount',
      'Uses async: $usesAsync',
      'Uses await: $usesAwait',
      '',
      'Note: counts are heuristic and do not replace a language parser or analyzer.',
    ].join('\n');
  }
}
