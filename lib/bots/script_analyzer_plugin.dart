import '../script_analyzer_bot.dart';
import 'bot.dart';

/// Adapts the existing ScriptAnalyzer implementation to the Web4ui bot API.
class ScriptAnalyzerPlugin implements Web4Bot {
  const ScriptAnalyzerPlugin();

  @override
  String get id => 'script-analyzer';

  @override
  String get name => 'Script Analyzer';

  @override
  Future<BotReport> run(String input) async {
    final analyzer = ScriptAnalyzer(input);
    return BotReport(
      botId: id,
      title: 'Script analysis',
      findings: <String>[
        'Comments found: ${analyzer.countComments()}',
        'Uses async/await: ${analyzer.usesAsyncAwait()}',
        'TODO/FIXME markers: ${analyzer.countTodoFixme()}',
        'Has long functions (>50 lines): ${analyzer.hasLongFunctions()}',
      ],
    );
  }
}
