import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BotLoader {
  final String configUrl;

  BotLoader({required this.configUrl});

  /// Load bots dynamically from a remote URL
  Future<void> loadBots() async {
    final response = await http.get(Uri.parse(configUrl));

    if (response.statusCode == 200) {
      final config = jsonDecode(response.body);

      for (var bot in config['bots']) {
        final botName = bot['name'];
        final botUrl = bot['url'];

        print('Loading bot: $botName from $botUrl');

        // Load the bot dynamically (Here we just print, but in reality, you would fetch the bot content)
        await loadBot(botUrl);
      }
    } else {
      print('Failed to load config: ${response.statusCode}');
    }
  }

  /// A mock method to simulate bot loading (e.g., fetch bot code or run it)
  Future<void> loadBot(String botUrl) async {
    // In a real app, you'd fetch the bot code from the URL
    print('Bot loaded from: $botUrl');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Dynamic Bot Loader")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final botLoader = BotLoader(configUrl: 'https://example.com/bots_config.json');
              await botLoader.loadBots();
            },
            child: Text("Load Bots"),
          ),
        ),
      ),
    );
  }
}
