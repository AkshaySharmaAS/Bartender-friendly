import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/api_key_dialog.dart';
import '../login_screen.dart';
import 'drinks_menu_screen.dart';
import 'customer_chat_screen.dart';
import 'my_requests_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DrinksMenuScreen(),
      CustomerChatScreen(),
      MyRequestsScreen(),
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
            const Text('🍸', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BarAI',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
                Text('Hi, ${user.name}',
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.key,
                color: cs.onSurface.withValues(alpha: 0.5)),
            tooltip: 'API Key',
            onPressed: () => ApiKeyDialog.show(context),
          ),
          IconButton(
            icon: Icon(Icons.logout,
                color: cs.onSurface.withValues(alpha: 0.5)),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(cs, isDark),
    );
  }

  Widget _buildBottomNav(ColorScheme cs, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Requests'),
        ],
      ),
    );
  }
}
