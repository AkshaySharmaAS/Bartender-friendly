import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeModeMenuButton extends StatelessWidget {
  const ThemeModeMenuButton({super.key});

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  String _labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'System theme';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme',
      initialValue: themeMode,
      icon: Icon(
        _iconFor(themeMode),
        color: cs.onSurface.withValues(alpha: 0.5),
      ),
      onSelected: (mode) => context.read<ThemeProvider>().setThemeMode(mode),
      itemBuilder: (context) => ThemeMode.values
          .map(
            (mode) => PopupMenuItem<ThemeMode>(
              value: mode,
              child: Row(
                children: [
                  Icon(_iconFor(mode), size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_labelFor(mode))),
                  if (mode == themeMode)
                    const Icon(Icons.check, size: 18),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
