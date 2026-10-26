import 'package:flutter_test/flutter_test.dart';
import 'package:web4ui/bot_system.dart';

class EchoBot implements Web4Bot {
  @override
  String get id => 'echo';
  @override
  String get name => 'Echo';
  @override
  String get description => 'Returns the input.';
  @override
  Future<BotResult> run(BotContext context) async => BotResult(
        botId: id,
        summary: context.input,
      );
}

void main() {
  group('BotRegistry', () {
    test('registers and runs a bot by ID', () async {
      final registry = BotRegistry([EchoBot()]);
      final result = await registry.run('echo', const BotContext(input: 'hello'));
      expect(result.botId, 'echo');
      expect(result.summary, 'hello');
    });

    test('rejects duplicate bot IDs', () {
      expect(() => BotRegistry([EchoBot(), EchoBot()]), throwsArgumentError);
    });

    test('reports unknown bot IDs', () async {
      final registry = BotRegistry([EchoBot()]);
      await expectLater(
        registry.run('missing', const BotContext(input: 'x')),
        throwsArgumentError,
      );
    });

    test('script analyzer is exposed through the common contract', () async {
      final registry = BotRegistry([ScriptAnalyzerPlugin()]);
      final result = await registry.run(
        'script-analyzer',
        const BotContext(input: '// TODO: improve\nvoid work() async { await task(); }'),
      );
      expect(result.details['commentCount'], 1);
      expect(result.details['todoFixmeCount'], 1);
      expect(result.details['usesAsyncAwait'], isTrue);
    });
  });
}
