import 'dart:convert';
import 'dart:io';

import 'bot.dart';

/// Registry for explicitly compiled-in bots.
///
/// Dart/Flutter does not safely import arbitrary Dart source files at runtime.
/// New bot classes must be imported and registered by the application.
class BotRegistry {
  BotRegistry(Iterable<Web4Bot> bots)
      : _bots = <String, Web4Bot>{
          for (final bot in bots) bot.id: bot,
        } {
    if (_bots.length != bots.length) {
      throw ArgumentError('Bot IDs must be unique.');
    }
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

  /// Reads an allowlist-style JSON config and returns only enabled registered
  /// bots. Configuration can enable/disable compiled-in bots, not load code.
  Future<List<Web4Bot>> enabledFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('Bot configuration not found', path);
    }
    final decoded = jsonDecode(await file.readAsString());
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
