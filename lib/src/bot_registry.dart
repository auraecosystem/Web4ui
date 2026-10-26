import 'dart:convert';

import 'bot.dart';

/// Registry for explicitly compiled-in bots.
///
/// Dart/Flutter does not safely import arbitrary Dart source files at runtime.
/// New bot classes must be imported and registered by the application.
class BotRegistry {
  BotRegistry(Iterable<Web4Bot> bots) : _bots = _indexBots(bots);

  static Map<String, Web4Bot> _indexBots(Iterable<Web4Bot> bots) {
    final indexed = <String, Web4Bot>{};
    for (final bot in bots) {
      if (indexed.containsKey(bot.id)) {
        throw ArgumentError('Bot IDs must be unique: ${bot.id}');
      }
      indexed[bot.id] = bot;
    }
    return indexed;
  }

  final Map<String, Web4Bot> _bots;

  List<Web4Bot> get bots => List.unmodifiable(_bots.values);

  Web4Bot? find(String id) => _bots[id];

  Future<BotResult> run(String id, BotContext context) {
    final bot = _bots[id];
    if (bot == null) {
      throw ArgumentError.value(id, 'id', 'No registered bot with this ID.');
    }
    return bot.run(context);
  }

  /// Selects enabled bots from JSON configuration. Configuration can enable or
  /// disable registered bots; it cannot load or execute source code.
  List<Web4Bot> enabledFromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> || decoded['bots'] is! List) {
      throw const FormatException('Expected an object containing a bots list.');
    }

    final enabled = <Web4Bot>[];
    final seen = <String>{};
    for (final entry in decoded['bots'] as List) {
      if (entry is! Map<String, dynamic> || entry['id'] is! String) {
        throw const FormatException('Each bot entry must include a string id.');
      }
      final id = entry['id'] as String;
      if (!seen.add(id)) {
        throw FormatException('Duplicate bot ID in configuration: $id');
      }
      final isEnabled = entry['enabled'] ?? true;
      if (isEnabled is! bool) {
        throw FormatException('The enabled flag for "$id" must be boolean.');
      }
      if (!isEnabled) continue;
      final bot = _bots[id];
      if (bot == null) {
        throw FormatException('Configured bot "$id" is not registered.');
      }
      enabled.add(bot);
    }
    return List.unmodifiable(enabled);
  }
}
