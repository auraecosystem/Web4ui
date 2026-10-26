import 'dart:convert';

import 'bot.dart';
import 'script_analyzer_plugin.dart';

/// Registry of explicitly compiled-in bots.
///
/// Configuration can enable/disable known bots, but cannot download or execute
/// arbitrary Dart code. Add new implementations to [builtIns] deliberately.
class BotRegistry {
  BotRegistry({List<Web4Bot>? builtIns})
      : _builtIns = List<Web4Bot>.unmodifiable(
          builtIns ?? const <Web4Bot>[ScriptAnalyzerPlugin()],
        ) {
    final ids = _builtIns.map((bot) => bot.id).toList();
    if (ids.toSet().length != ids.length || ids.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('Built-in bot IDs must be unique and non-empty.');
    }
  }

  final List<Web4Bot> _builtIns;
  List<Web4Bot> _active = const <Web4Bot>[];

  List<Web4Bot> get activeBots => List<Web4Bot>.unmodifiable(_active);

  /// Loads an allow-list configuration such as Bot/bots_config.json.
  /// Missing [bots] means all built-ins are enabled; unknown IDs are rejected.
  void configure(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Bot configuration must be a JSON object.');
    }
    final rawBots = decoded['bots'];
    if (rawBots == null) {
      _active = List<Web4Bot>.unmodifiable(_builtIns);
      return;
    }
    if (rawBots is! List) {
      throw const FormatException('The "bots" property must be a list.');
    }

    final enabledIds = <String>{};
    final seenIds = <String>{};
    for (final item in rawBots) {
      if (item is! Map<String, dynamic> || item['id'] is! String) {
        throw const FormatException('Each bot entry must contain a string id.');
      }
      final id = (item['id'] as String).trim();
      if (id.isEmpty) {
        throw const FormatException('Bot IDs must not be empty.');
      }
      if (!seenIds.add(id)) {
        throw FormatException('Duplicate bot ID in configuration: $id');
      }
      final enabled = item['enabled'];
      if (enabled != null && enabled is! bool) {
        throw const FormatException('Bot "enabled" must be a boolean.');
      }
      if (enabled != false) enabledIds.add(id);
    }

    final knownIds = _builtIns.map((bot) => bot.id).toSet();
    final unknownIds = enabledIds.difference(knownIds);
    if (unknownIds.isNotEmpty) {
      throw FormatException('Unknown bot id(s): ${unknownIds.join(', ')}');
    }
    _active = List<Web4Bot>.unmodifiable(
      _builtIns.where((bot) => enabledIds.contains(bot.id)),
    );
  }

  Future<List<BotReport>> runAll(String input) async {
    final reports = <BotReport>[];
    for (final bot in _active) {
      reports.add(await bot.run(input));
    }
    return List<BotReport>.unmodifiable(reports);
  }
}
