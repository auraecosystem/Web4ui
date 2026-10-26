import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bots/bot_registry.dart';
import 'bots/bot.dart';

void main() => runApp(const Web4uiApp());

class Web4uiApp extends StatelessWidget {
  const Web4uiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Web4ui',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
        home: const ScriptAnalyzerPage(),
      );
}

class ScriptAnalyzerPage extends StatefulWidget {
  const ScriptAnalyzerPage({super.key});

  @override
  State<ScriptAnalyzerPage> createState() => _ScriptAnalyzerPageState();
}

class _ScriptAnalyzerPageState extends State<ScriptAnalyzerPage> {
  final _scriptController = TextEditingController(text: '// TODO: review this script\nvoid main() async {\n  await work();\n}');
  final _registry = BotRegistry();
  List<BotReport> _reports = const <BotReport>[];
  String? _error;
  bool _busy = false;

  Future<void> _analyze() async {
    setState(() { _busy = true; _error = null; });
    try {
      final config = await rootBundle.loadString('Bot/bots_config.json');
      _registry.configure(config);
      final reports = await _registry.runAll(_scriptController.text);
      if (!mounted) return;
      setState(() => _reports = reports);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not run analysis: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Web4ui Script Analyzer')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text('Enter a script to run the locally registered analysis bots.'),
            const SizedBox(height: 12),
            TextField(
              controller: _scriptController,
              minLines: 8,
              maxLines: 16,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(labelText: 'Script source', border: OutlineInputBorder(), alignLabelWithHint: true),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _analyze,
              icon: const Icon(Icons.analytics_outlined),
              label: Text(_busy ? 'Analyzing…' : 'Analyze script'),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            for (final report in _reports) ...<Widget>[
              const SizedBox(height: 20),
              Text(report.title, style: Theme.of(context).textTheme.titleLarge),
              for (final finding in report.findings)
                ListTile(dense: true, leading: const Icon(Icons.check_circle_outline), title: Text(finding)),
            ],
          ],
        ),
      );
}
