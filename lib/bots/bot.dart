/// Stable contract implemented by every locally registered Web4ui bot.
abstract interface class Web4Bot {
  String get id;
  String get name;
  Future<BotReport> run(String input);
}

/// Structured output that the UI, tests, and other bots can consume.
class BotReport {
  const BotReport({required this.botId, required this.title, required this.findings});

  final String botId;
  final String title;
  final List<String> findings;
}
