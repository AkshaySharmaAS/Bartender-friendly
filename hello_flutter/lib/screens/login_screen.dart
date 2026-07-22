import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/theme_mode_menu_button.dart';
import 'customer/customer_home_screen.dart';
import 'bartender/bartender_home_screen.dart';
import 'admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _setRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _emailCtrl.clear();
      _passwordCtrl.clear();
    });
    context.read<AuthProvider>().clearError();

    // Pre-fill demo credentials
    switch (role) {
      case UserRole.admin:
        _emailCtrl.text = 'admin@bar.com';
        _passwordCtrl.text = 'admin123';
        break;
      case UserRole.bartender:
        _emailCtrl.text = 'bartender@bar.com';
        _passwordCtrl.text = 'bar123';
        break;
      case UserRole.customer:
        _emailCtrl.text = 'customer@bar.com';
        _passwordCtrl.text = 'cust123';
        break;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
        _emailCtrl.text.trim(), _passwordCtrl.text.trim(), _selectedRole);

    if (ok && mounted) {
      final user = auth.currentUser!;
      Widget next;
      switch (user.role) {
        case UserRole.customer:
          next = const CustomerHomeScreen();
          break;
        case UserRole.bartender:
          next = const BartenderHomeScreen();
          break;
        case UserRole.admin:
          next = const AdminHomeScreen();
          break;
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => next));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: ThemeModeMenuButton(),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 30),
                // Logo
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('🍸', style: TextStyle(fontSize: 38)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'BarAI',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Your AI-powered cocktail bar',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Role selector
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login as',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: UserRole.values
                      .map((role) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: role == UserRole.admin ? 0 : 8),
                              child: _RoleButton(
                                role: role,
                                selected: _selectedRole == role,
                                onTap: () => _setRole(role),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter your email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: cs.onSurface.withValues(alpha: 0.4),
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter your password'
                            : null,
                      ),
                    ],
                  ),
                ),

                // Error message
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: cs.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: cs.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: cs.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: TextStyle(
                                    color: cs.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 26),

                // Login button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: cs.onPrimary, strokeWidth: 2),
                              )
                            : const Text('Sign In'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),
                // Demo hint
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.surfaceVariant.withValues(alpha: 0.5)
                        : cs.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🎯 Demo Credentials',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _credRow(context, 'Customer', 'customer@bar.com', 'cust123'),
                      _credRow(context, 'Bartender', 'bartender@bar.com', 'bar123'),
                      _credRow(context, 'Admin', 'admin@bar.com', 'admin123'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _credRow(BuildContext context, String role, String email, String pwd) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(role,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.55), fontSize: 12)),
          ),
          Expanded(
            child: Text(email,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
          ),
          Text(pwd,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: cs.onSurface),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20,
            color: cs.onSurface.withValues(alpha: 0.4)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  String get _emoji {
    switch (role) {
      case UserRole.customer:
        return '👤';
      case UserRole.bartender:
        return '🍹';
      case UserRole.admin:
        return '⚙️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              role.displayName,
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
