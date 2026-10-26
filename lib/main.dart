import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bot_system.dart';

void main() {
  runApp(const Web4uiApp());
}

class Web4uiApp extends StatelessWidget {
  const Web4uiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web4ui',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const BotWorkbenchPage(),
    );
  }
}

class BotWorkbenchPage extends StatefulWidget {
  const BotWorkbenchPage({super.key});

  @override
  State<BotWorkbenchPage> createState() => _BotWorkbenchPageState();
}

class _BotWorkbenchPageState extends State<BotWorkbenchPage> {
  final _scriptController = TextEditingController(
    text: '// TODO: review this code\nvoid main() async {\n  await task();\n}',
  );
  final _registry = BotRegistry([ScriptAnalyzerPlugin()]);
  String? _report;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  Future<void> _runAnalyzer() async {
    setState(() {
      _busy = true;
      _error = null;
      _report = null;
    });
    try {
      final config = await rootBundle.loadString('config/bots.json');
      final enabledBots = _registry.enabledFromJson(config);
      final analyzer = enabledBots.where((bot) => bot.id == 'script-analyzer');
      if (analyzer.isEmpty) {
        throw StateError('Script Analyzer is disabled in config/bots.json.');
      }
      final result = await _registry.run(
        'script-analyzer',
        BotContext(input: _scriptController.text),
      );
      if (!mounted) return;
      setState(() {
        _report = result.details.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join('\n');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web4ui Bot Workbench')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Registered bots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text('Script Analyzer'),
            subtitle: Text('Analyze comments, TODOs, async/await, and script size.'),
          ),
          const SizedBox(height: 16),
          Text('Script input', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _scriptController,
            minLines: 7,
            maxLines: 14,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste script code to analyze',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _runAnalyzer,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_busy ? 'Analyzing…' : 'Analyze script'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_report != null) ...[
            const SizedBox(height: 16),
            Text('Analysis report', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(_report!),
          ],
        ],
      ),
    );
  }
}
