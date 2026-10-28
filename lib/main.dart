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

import 'script_metrics.dart';

import 'bots/bot.dart';
import 'bots/bot_registry.dart';

const _bg = Color(0xFF1E1F22);
const _sidebar = Color(0xFF2B2D31);
const _panel = Color(0xFF313338);
const _raised = Color(0xFF383A40);
const _line = Color(0xFF41434A);
const _muted = Color(0xFFB5BAC1);
const _accent = Color(0xFF5865F2);
const _green = Color(0xFF57D9A3);

void main() => runApp(const Web4uiApp());

class Web4uiApp extends StatelessWidget {
  const Web4uiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Web4ui',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _bg,
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            secondary: Color(0xFF8EA1E1),
            surface: _panel,
            error: Color(0xFFFA777C),
          ),
          dividerColor: _line,
          appBarTheme: const AppBarTheme(
            backgroundColor: _bg,
            foregroundColor: Color(0xFFF2F3F5),
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _bg,
            hintStyle: const TextStyle(color: _muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        home: const ScriptAnalyzerPage(),
      );
}

class ScriptAnalyzerPage extends StatefulWidget {
  const ScriptAnalyzerPage({super.key});

  @override
  State<ScriptAnalyzerPage> createState() => _ScriptAnalyzerPageState();
}

class _ScriptAnalyzerPageState extends State<ScriptAnalyzerPage> {
  final _scriptController = TextEditingController(
    text: '// TODO: review this script\nvoid main() async {\n  await work();\n}',
  );
  final _registry = BotRegistry();
  List<BotReport> _reports = const <BotReport>[];
  String? _error;
  bool _busy = false;

  Future<void> _analyze() async {
    setState(() {
      _busy = true;
      _error = null;
    });
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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  if (!compact) const _Sidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _TopBar(compact: compact),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(compact ? 16 : 28),
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.tag_rounded, color: _muted, size: 26),
                                  SizedBox(width: 8),
                                  Text('script-analyzer',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'A focused workspace for your local analysis bots.',
                                style: TextStyle(color: _muted, height: 1.5),
                              ),
                              const SizedBox(height: 22),
                              _WelcomeCard(),
                              const SizedBox(height: 20),
                              _editorCard(compact),
                              const SizedBox(height: 14),
                              _metricsCard(),
                              const SizedBox(height: 20),
                              _resultsCard(),
                              const SizedBox(height: 20),
                              const Center(
                                child: Text(
                                  'Web4ui · Local-first tools · Bot registry preserved',
                                  style: TextStyle(color: _muted, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _editorCard(bool compact) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.terminal_rounded,
              color: Color(0xFF8EA1E1),
              title: 'Script workspace',
              subtitle: 'Edit source and run your registered local analyzer',
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF232428),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _line)),
                    ),
                    child: const Row(
                      children: [
                        _WindowDot(color: Color(0xFFED6A5E)),
                        SizedBox(width: 6),
                        _WindowDot(color: Color(0xFFF4BF4F)),
                        SizedBox(width: 6),
                        _WindowDot(color: Color(0xFF61C554)),
                        SizedBox(width: 12),
                        Text('script.dart',
                            style: TextStyle(color: _muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _scriptController,
                    onChanged: (_) => setState(() {}),
                    minLines: compact ? 9 : 12,
                    maxLines: 22,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.65,
                      color: Color(0xFFE3E7FF),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Paste or write your script…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2529),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: Color(0xFFFFB7BB))),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _analyze,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(_busy ? 'Analyzing…' : 'Run analysis'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _scriptController.clear();
                            _reports = const <BotReport>[];
                            _error = null;
                          }),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Clear workspace'),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _metricsCard() {
    final metrics = ScriptMetrics.fromSource(_scriptController.text);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _MetricChip(label: 'Lines', value: '${metrics.lineCount}', icon: Icons.format_list_numbered_rounded),
        _MetricChip(label: 'Characters', value: '${metrics.characterCount}', icon: Icons.text_fields_rounded),
        _MetricChip(label: 'TODO', value: '${metrics.todoCount}', icon: Icons.checklist_rounded),
        _MetricChip(label: 'FIXME', value: '${metrics.fixmeCount}', icon: Icons.flag_outlined),
      ],
    );
  }

  Widget _resultsCard() => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.fact_check_outlined,
              color: _green,
              title: 'Analysis reports',
              subtitle: 'Findings returned by enabled local bots',
            ),
            const SizedBox(height: 16),
            if (_reports.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF292B30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _line),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 30, color: _muted),
                    SizedBox(height: 10),
                    Text('Your reports will appear here',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 5),
                    Text(
                      'Run an analysis to see findings from your configured bots.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              )
            else
              for (final report in _reports)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF292B30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.smart_toy_outlined,
                              color: Color(0xFF8EA1E1)),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(report.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (final finding in report.findings)
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: _green, size: 17),
                              const SizedBox(width: 9),
                              Expanded(child: Text(finding)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
          ],
        ),
      );
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: _muted),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(width: 7),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) => Container(
        width: 228,
        color: _sidebar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _line)),
              ),
              child: const Row(
                children: [
                  _BrandMark(),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text('Web4ui',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 12, 9),
              child: Text('WORKSPACE',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  )),
            ),
            const _NavItem(icon: Icons.tag_rounded, label: 'script-analyzer', selected: true),
            const _NavItem(icon: Icons.smart_toy_outlined, label: 'local-bots'),
            const _NavItem(icon: Icons.science_outlined, label: 'experiments'),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF232428),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Color(0xFF3B3D46),
                    child: Icon(Icons.person_outline, size: 19),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Local workspace',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                        SizedBox(height: 3),
                        Text('Private session',
                            style: TextStyle(color: _muted, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
        decoration: const BoxDecoration(
          color: _bg,
          border: Border(bottom: BorderSide(color: _line)),
        ),
        child: Row(
          children: [
            if (compact) ...[
              const _BrandMark(size: 30),
              const SizedBox(width: 10),
              const Text('Web4ui',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              const Text('/', style: TextStyle(color: _muted)),
              const SizedBox(width: 10),
            ],
            const Icon(Icons.tag_rounded, color: _muted, size: 22),
            const SizedBox(width: 9),
            const Expanded(
              child: Text('script-analyzer',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const Icon(Icons.search_rounded, color: _muted),
            const SizedBox(width: 16),
            const Icon(Icons.help_outline_rounded, color: _muted),
          ],
        ),
      );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF373C66), _panel],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF555D99)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconTile(icon: Icons.auto_awesome_rounded, color: Color(0xFFB8C2FF)),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to your workspace',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text(
                    'Run your registered analysis bots locally. This interface keeps the existing compiled-in bot registry and does not download or execute remote bot code.',
                    style: TextStyle(color: Color(0xFFD5D8F2), height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _line.withOpacity(0.8)),
        ),
        child: child,
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _IconTile(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
          if (title == 'Script workspace')
            const _Pill(label: 'LOCAL ONLY', color: _green),
        ],
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 21),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 34});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accent, Color(0xFF8EA1E1)],
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(Icons.bubble_chart_rounded,
            color: Colors.white, size: size * 0.63),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF404249) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          leading: Icon(icon, size: 20, color: selected ? Colors.white : _muted),
          title: Text(label, style: TextStyle(
            color: selected ? Colors.white : _muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          )),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          minLeadingWidth: 18,
        ),
      );
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(label, style: TextStyle(
          color: color,
          fontSize: 9,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w900,
        )),
      );
}
