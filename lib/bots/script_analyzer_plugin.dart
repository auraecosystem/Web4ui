import '../script_analyzer_bot.dart' as analyzer;
import '../src/bot.dart';

/// Adapts Web4ui's existing script analyzer to the common bot interface.
class ScriptAnalyzerPlugin implements Web4Bot {
  @override
  String get id => 'script-analyzer';

  @override
  String get name => 'Script Analyzer';

  @override
  String get description =>
      'Counts comments and TODO/FIXME markers and checks async/await usage.';

  @override
  Future<BotResult> run(BotContext context) async {
    final script = context.input;
    final result = analyzer.ScriptAnalyzer(script);

    final details = <String, Object?>{
      'commentCount': result.countComments(),
      'usesAsyncAwait': result.usesAsyncAwait(),
      'todoFixmeCount': result.countTodoFixme(),
      'hasLongFunctions': result.hasLongFunctions(),
      'lineCount': script.isEmpty ? 0 : '\n'.allMatches(script).length + 1,
    };

    return BotResult(
      botId: id,
      summary: 'Script analysis completed.',
      details: details,
    );
  }
}
