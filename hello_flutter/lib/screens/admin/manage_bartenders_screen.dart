import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/user.dart';
import '../../providers/user_management_provider.dart';

class ManageBartendersScreen extends StatefulWidget {
  const ManageBartendersScreen({super.key});

  @override
  State<ManageBartendersScreen> createState() =>
      _ManageBartendersScreenState();
}

class _ManageBartendersScreenState extends State<ManageBartendersScreen> {
  static const _uuid = Uuid();

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Row(
            children: [
              Text('🍹', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Add Bartender'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, 'Full Name', Icons.person_outline,
                    (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                _field(emailCtrl, 'Email', Icons.email_outlined,
                    (v) => v!.isEmpty ? 'Required' : null,
                    inputType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pwdCtrl,
                  obscureText: obscure,
                  validator: (v) =>
                      v == null || v.length < 4 ? 'Min 4 characters' : null,
                  decoration: _inputDecoration(
                    'Password',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          size: 18),
                      onPressed: () => setS(() => obscure = !obscure),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final user = User(
                  id: _uuid.v4(),
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim().toLowerCase(),
                  password: pwdCtrl.text.trim(),
                  role: UserRole.bartender,
                );
                context.read<UserManagementProvider>().addUser(user);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name} added as bartender.')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Bartender'),
        content: Text('Remove ${user.name} from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserManagementProvider>().removeUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} removed.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, _) {
          final bartenders = provider.bartenders;

          if (bartenders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🍹', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text('No bartenders yet',
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Bartender'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: bartenders.length,
            itemBuilder: (context, i) {
              final b = bartenders[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: isDark
                      ? Border.all(
                          color: cs.primary.withValues(alpha: 0.3))
                      : null,
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Text('🍹',
                              style: TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name,
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(b.email,
                              style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: cs.error, size: 22),
                      onPressed: () => _confirmDelete(context, b),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Bartender'),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? inputType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      suffixIcon: suffix,
    );
  }
}
