import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const CourseworkApp());
}

class CourseworkApp extends StatefulWidget {
  const CourseworkApp({super.key});

  @override
  State<CourseworkApp> createState() => _CourseworkAppState();
}

class _CourseworkAppState extends State<CourseworkApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 Counter & Toggle',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const int _goal = 20;

  int _counter = 0;
  int _step = 1;
  bool _isFirstImage = true;
  final List<int> _history = <int>[];

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recordHistory() {
    _history.add(_counter);
  }

  void _incrementCounter() {
    _recordHistory();
    setState(() {
      _counter += _step;
    });
  }

  void _quickAdd(int value) {
    _recordHistory();
    setState(() {
      _counter += value;
    });
  }

  void _decrementCounter() {
    if (_counter == 0) return;
    _recordHistory();
    setState(() {
      _counter = math.max(0, _counter - _step);
    });
  }

  void _resetCounter() {
    if (_counter == 0) return;
    _recordHistory();
    setState(() {
      _counter = 0;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _counter = _history.removeLast();
    });
  }

  Future<void> _toggleImage() async {
    await _controller.reverse();
    setState(() {
      _isFirstImage = !_isFirstImage;
    });
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_counter / _goal).clamp(0, 1);
    final bool isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CW1 Counter & Toggle'),
        actions: <Widget>[
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Counter: $_counter',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Current step: $_step',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: <int>[1, 5, 10]
                      .map(
                        (int value) => ChoiceChip(
                          label: Text('Step $value'),
                          selected: _step == value,
                          onSelected: (_) {
                            setState(() {
                              _step = value;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _incrementCounter,
                      child: const Text('Increment'),
                    ),
                    OutlinedButton(
                      onPressed: _counter > 0 ? _decrementCounter : null,
                      child: const Text('Decrement'),
                    ),
                    OutlinedButton(
                      onPressed: _counter > 0 ? _resetCounter : null,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: () => _quickAdd(1),
                      child: const Text('+1'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _quickAdd(5),
                      child: const Text('+5'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _quickAdd(10),
                      child: const Text('+10'),
                    ),
                    FilledButton.tonal(
                      onPressed: _history.isNotEmpty ? _undo : null,
                      child: const Text('Undo'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text(
                  'Goal: $_goal',
                  textAlign: TextAlign.center,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _counter >= _goal
                      ? Text(
                          'Goal reached!',
                          key: const ValueKey<String>('goal_reached'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : const SizedBox.shrink(
                          key: ValueKey<String>('goal_not_reached'),
                        ),
                ),
                const Divider(height: 36),
                Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Image.asset(
                        _isFirstImage
                            ? 'assets/Sinister.jpeg'
                            : 'assets/Omni.jpeg',
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _toggleImage,
                  child: const Text('Toggle Image'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: widget.onToggleTheme,
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  label: Text(
                    isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
