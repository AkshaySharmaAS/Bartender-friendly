import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/drink.dart';
import '../providers/drink_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/groq_service.dart';

class SaveRecipeDialog extends StatefulWidget {
  final String recipeContent;

  const SaveRecipeDialog({super.key, required this.recipeContent});

  static Future<void> show(BuildContext context,
      {required String recipeContent}) {
    return showDialog(
      context: context,
      builder: (_) => SaveRecipeDialog(recipeContent: recipeContent),
    );
  }

  @override
  State<SaveRecipeDialog> createState() => _SaveRecipeDialogState();
}

class _SaveRecipeDialogState extends State<SaveRecipeDialog> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DrinkType _type = DrinkType.cocktail;
  bool _isPopular = false;
  bool _isSuggestingName = false;
  bool _isSaving = false;

  static const _uuid = Uuid();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _suggestName() async {
    final chatProvider = context.read<ChatProvider>();
    if (!chatProvider.hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set your Groq API key first.')),
      );
      return;
    }
    setState(() => _isSuggestingName = true);
    try {
      final groq = GroqService(chatProvider.apiKey!);
      final name = await groq.suggestDrinkName(
        recipeContent: widget.recipeContent,
        drinkType: _type.displayName,
      );
      if (mounted) {
        setState(() => _nameCtrl.text = name.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not suggest name: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSuggestingName = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final bartenderId =
        context.read<AuthProvider>().currentUser?.id;

    // Extract a short description from the first meaningful line
    final lines = widget.recipeContent
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'^[#*\->\s]+'), '').trim())
        .where((l) => l.isNotEmpty && l.length > 10)
        .toList();
    final description = lines.isNotEmpty
        ? lines.first.length > 120
            ? '${lines.first.substring(0, 117)}...'
            : lines.first
        : 'AI-generated ${_type.displayName} recipe.';

    final drink = Drink(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      description: description,
      ingredients: ['See recipe for full ingredients'],
      recipe: widget.recipeContent,
      isPopular: _isPopular,
      createdBy: bartenderId,
    );

    context.read<DrinkProvider>().addDrink(drink);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${drink.name} saved to menu! 🍹')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: const Row(
        children: [
          Text('💾', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text('Save as Drink'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save this AI recipe to your drinks menu.',
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.55), fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Type selector
              Row(
                children: [
                  _TypeChip(
                    label: '🍸 Cocktail',
                    selected: _type == DrinkType.cocktail,
                    onTap: () => setState(() => _type = DrinkType.cocktail),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: '🥤 Mocktail',
                    selected: _type == DrinkType.mocktail,
                    onTap: () => setState(() => _type = DrinkType.mocktail),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Name field + AI suggest button
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: cs.onSurface),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a name' : null,
                decoration: InputDecoration(
                  labelText: 'Drink Name *',
                  suffixIcon: _isSuggestingName
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: cs.secondary),
                          ),
                        )
                      : Tooltip(
                          message: 'AI Suggest Name',
                          child: IconButton(
                            icon: const Text('✨',
                                style: TextStyle(fontSize: 18)),
                            onPressed: _suggestName,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isSuggestingName ? null : _suggestName,
                child: Text(
                  '✨ Tap the sparkle icon to auto-suggest a name with AI',
                  style: TextStyle(
                    color: cs.secondary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Popular toggle
              Row(
                children: [
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: _isPopular,
                      onChanged: (v) => setState(() => _isPopular = v),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Mark as Popular',
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.65),
                          fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          icon: _isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_alt, size: 16),
          label: const Text('Save to Menu'),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
