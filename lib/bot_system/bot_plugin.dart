/// Contract implemented by each bot that is compiled into the Web4ui app.
abstract interface class BotPlugin {
  String get id;
  String get name;
  String get description;

  /// Runs this bot against user-provided text and returns a readable report.
  Future<String> run(String input);
}
