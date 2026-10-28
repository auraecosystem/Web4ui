import '../script_analyzer_bot.dart';
import 'bot.dart';

/// Adapts the existing ScriptAnalyzer to Web4ui's local bot contract.
class ScriptAnalyzerPlugin implements Web4Bot {
  const ScriptAnalyzerPlugin();

  @override
  String get id => 'script-analyzer';

  @override
  String get name => 'Script Analyzer';

  @override
  String get description =>
      'Counts comments and TODO/FIXME markers and checks async/await usage.';

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
