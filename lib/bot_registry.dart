/// Minimal, explicit registry for executable in-process bots.
///
/// Dart/Flutter does not support importing and executing arbitrary Dart source
/// files downloaded at runtime. Register trusted bot implementations at build
/// time instead of executing remote code.
abstract interface class Web4Bot {
  String get id;
  String get description;

  Future<BotReport> run(String source);
}

class BotReport {
  const BotReport({
    required this.botId,
    required this.summary,
    this.findings = const [],
  });

  final String botId;
  final String summary;
  final List<String> findings;
}

class BotRegistry {
  final Map<String, Web4Bot> _bots = {};

  Iterable<Web4Bot> get bots => List.unmodifiable(_bots.values);

  void register(Web4Bot bot) {
    final id = bot.id.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(bot.id, 'bot.id', 'Must not be empty.');
    }
    if (_bots.containsKey(id)) {
      throw StateError('A bot with id "$id" is already registered.');
    }
    _bots[id] = bot;
  }

  Web4Bot? find(String id) => _bots[id];

  Future<BotReport> run(String id, String source) {
    final bot = _bots[id];
    if (bot == null) {
      throw StateError('No bot registered with id "$id".');
    }
    return bot.run(source);
  }
}

/// A small built-in bot demonstrating the registry contract.
class ScriptMetricsBot implements Web4Bot {
  @override
  String get id => 'script-metrics';

  @override
  String get description => 'Reports basic source metrics and TODO/FIXME markers.';

  @override
  Future<BotReport> run(String source) async {
    final lines = source.isEmpty ? 0 : '\n'.allMatches(source).length + 1;
    final todoPattern = RegExp(r'\b(?:TODO|FIXME)\b', caseSensitive: false);
    final todoCount = todoPattern.allMatches(source).length;
    final asyncCount = RegExp(r'\basync\b').allMatches(source).length;
    final awaitCount = RegExp(r'\bawait\b').allMatches(source).length;

    return BotReport(
      botId: id,
      summary: '$lines lines; $todoCount TODO/FIXME marker(s); '
          '$asyncCount async keyword(s); $awaitCount await keyword(s).',
      findings: todoCount == 0
          ? const []
          : ['$todoCount TODO/FIXME marker(s) need review.'],
    );
  }
}
