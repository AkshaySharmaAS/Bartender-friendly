import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/drink_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/request_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

class BarAiApp extends StatelessWidget {
  const BarAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)..initialize()),
        ChangeNotifierProvider(create: (_) => DrinkProvider(storage)),
        ChangeNotifierProvider(create: (_) => ChatProvider(storage)),
        ChangeNotifierProvider(create: (_) => RequestProvider(storage)),
        ChangeNotifierProvider(create: (_) => UserManagementProvider(storage)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BarAI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
