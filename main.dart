import 'package:web4ui/bot_system.dart';

Future<void> main() async {
  const sample = '''
// TODO: replace this example with your script
void main() async {
  await doSomething();
}
''';

  final registry = BotRegistry([ScriptAnalyzerPlugin()]);
  final result = await registry.run(
    'script-analyzer',
    const BotContext(input: sample),
  );
  print(result.summary);
  result.details.forEach((key, value) => print('$key: $value'));
}
