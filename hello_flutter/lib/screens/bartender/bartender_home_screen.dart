import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/api_key_dialog.dart';
import '../login_screen.dart';
import 'manage_drinks_screen.dart';
import 'ai_recipe_screen.dart';
import 'customer_requests_screen.dart';

class BartenderHomeScreen extends StatefulWidget {
  const BartenderHomeScreen({super.key});

  @override
  State<BartenderHomeScreen> createState() => _BartenderHomeScreenState();
}

class _BartenderHomeScreenState extends State<BartenderHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      ManageDrinksScreen(),
      AiRecipeScreen(),
      CustomerRequestsScreen(),
    ];
    context.read<ChatProvider>().loadApiKey();
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🍹', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bartender Panel',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(user.name,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.key, color: cs.onSurface.withValues(alpha: 0.5)),
            tooltip: 'API Key',
            onPressed: () => ApiKeyDialog.show(context),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: cs.onSurface.withValues(alpha: 0.5)),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.liquor), label: 'Drinks'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Recipe'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Requests'),
        ],
      ),
    );
  }
}
