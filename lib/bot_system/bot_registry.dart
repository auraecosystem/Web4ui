import 'bot_plugin.dart';

/// Registry for bot implementations that are compiled into the application.
///
/// Flutter apps cannot safely import and execute arbitrary Dart source fetched
/// from a URL at runtime. Add a plugin implementation to the app and register
/// it here; a remote manifest may describe plugins but must not execute code.
class BotRegistry {
  final Map<String, BotPlugin> _plugins = <String, BotPlugin>{};

  List<BotPlugin> get plugins =>
      List<BotPlugin>.unmodifiable(_plugins.values);

  void register(BotPlugin plugin) {
    final id = plugin.id.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(plugin.id, 'plugin.id', 'Must not be empty.');
    }
    if (_plugins.containsKey(id)) {
      throw StateError('A bot with id "$id" is already registered.');
    }
    _plugins[id] = plugin;
  }

  BotPlugin? find(String id) => _plugins[id];

  Future<String> run(String id, String input) async {
    final plugin = _plugins[id];
    if (plugin == null) {
      throw ArgumentError('No bot registered with id "$id".');
    }
    return plugin.run(input);
  }
}
