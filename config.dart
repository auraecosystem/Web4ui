/// Compatibility exports for older imports of config.dart.
///
/// Bot selection now uses BotRegistry and the local Bot/bots_config.json
/// allowlist. Remote Dart source is never downloaded or executed.
export 'lib/bots/bot.dart';
export 'lib/bots/bot_registry.dart';
export 'lib/bots/script_analyzer_plugin.dart';
