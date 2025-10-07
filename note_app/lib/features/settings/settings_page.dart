import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  double? _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = ref.read(fontSizeProvider);
    _loadFontSize();
    _loadThemeMode();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('fontSize');
    if (saved != null) {
      setState(() {
        _fontSize = saved;
        ref.read(fontSizeProvider.notifier).state = saved;
      });
    }
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', value);
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode');
    if (themeString != null) {
      final mode = themeString == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
      ref.read(themeModeProvider.notifier).state = mode;
      setState(() {});
    }
  }

  Future<void> _saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode == AppThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = (_fontSize ?? ref.watch(fontSizeProvider)) ?? 16.0;
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Font Settings', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Font Size'),
                        const SizedBox(width: 16),
                        Text(fontSize.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      min: 12,
                      max: 32,
                      divisions: 20,
                      value: fontSize,
                      onChanged: (v) {
                        setState(() => _fontSize = v);
                        ref.read(fontSizeProvider.notifier).state = v;
                        _saveFontSize(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Example Text',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme Settings', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(themeModeProvider.notifier).state = AppThemeMode.light;
                            _saveThemeMode(AppThemeMode.light);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeMode == AppThemeMode.light ? Colors.blue : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Light'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(themeModeProvider.notifier).state = AppThemeMode.dark;
                            _saveThemeMode(AppThemeMode.dark);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeMode == AppThemeMode.dark ? Colors.blue : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Dark'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}