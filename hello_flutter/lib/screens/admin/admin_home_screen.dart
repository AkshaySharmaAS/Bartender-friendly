import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drink_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/api_key_dialog.dart';
import '../../widgets/theme_mode_menu_button.dart';
import '../login_screen.dart';
import 'manage_bartenders_screen.dart';
import 'admin_drinks_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      AdminOverviewTab(),
      ManageBartendersScreen(),
      AdminDrinksScreen(),
    ];
    context.read<UserManagementProvider>().loadUsers();
    context.read<DrinkProvider>().loadDrinks();
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('⚙️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Panel',
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
          const ThemeModeMenuButton(),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Bartenders'),
          BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Drinks'),
        ],
      ),
    );
  }
}

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final drinks = context.watch<DrinkProvider>().drinks;
    final users = context.watch<UserManagementProvider>().users;
    final bartenders = users.where((u) => u.role.name == 'bartender').length;
    final customers = users.where((u) => u.role.name == 'customer').length;
    final cocktails = drinks.where((d) => d.type.name == 'cocktail').length;
    final mocktails = drinks.where((d) => d.type.name == 'mocktail').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Bar statistics at a glance',
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13)),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              _StatCard(label: 'Bartenders', value: '$bartenders', icon: '🍹', color: cs.primary),
              _StatCard(label: 'Customers', value: '$customers', icon: '👥', color: cs.tertiary),
              _StatCard(label: 'Cocktails', value: '$cocktails', icon: '🍸', color: cs.secondary),
              _StatCard(label: 'Mocktails', value: '$mocktails', icon: '🥤', color: cs.tertiary),
            ],
          ),
          const SizedBox(height: 28),
          Text('Quick Actions',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _QuickAction(
            icon: Icons.person_add,
            label: 'Add Bartender',
            subtitle: 'Register a new bartender account',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.local_bar,
            label: 'Manage Drinks',
            subtitle: 'Add or remove cocktails and mocktails',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: cs.outline.withValues(alpha: 0.6))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bar_chart, color: color, size: 14),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.55),
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? Border.all(color: cs.outline.withValues(alpha: 0.6))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: cs.onSurface.withValues(alpha: 0.35)),
        ],
      ),
    );
  }
}
