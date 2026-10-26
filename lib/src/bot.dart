/// Contracts shared by Web4ui's built-in and future bots.
abstract interface class Web4Bot {
  String get id;
  String get name;
  String get description;

  Future<BotResult> run(BotContext context);
}

/// Explicit input passed to a bot.
class BotContext {
  const BotContext({required this.input});
  final String input;
}

/// A structured, UI-independent bot response.
class BotResult {
  const BotResult({
    required this.botId,
    required this.summary,
    this.details = const <String, Object?>{},
  });

  final String botId;
  final String summary;
  final Map<String, Object?> details;
}
