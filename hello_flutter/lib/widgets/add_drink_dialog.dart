import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/drink.dart';
import '../providers/drink_provider.dart';
import '../providers/chat_provider.dart';
import '../services/groq_service.dart';

class AddDrinkDialog extends StatefulWidget {
  final String? bartenderId;

  const AddDrinkDialog({super.key, this.bartenderId});

  static Future<void> show(BuildContext context, {String? bartenderId}) {
    return showDialog(
      context: context,
      builder: (_) => AddDrinkDialog(bartenderId: bartenderId),
    );
  }

  @override
  State<AddDrinkDialog> createState() => _AddDrinkDialogState();
}

class _AddDrinkDialogState extends State<AddDrinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _recipeCtrl = TextEditingController();
  final _ingredientCtrl = TextEditingController();

  DrinkType _type = DrinkType.cocktail;
  bool _isPopular = false;
  final List<String> _ingredients = [];
  bool _isGenerating = false;

  static const _uuid = Uuid();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _recipeCtrl.dispose();
    _ingredientCtrl.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final text = _ingredientCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(text);
        _ingredientCtrl.clear();
      });
    }
  }

  Future<void> _generateWithAI() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a drink name first.')),
      );
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    if (!chatProvider.hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Set your Groq API key in Settings first.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final groq = GroqService(chatProvider.apiKey!);
      final result = await groq.generateRecipe(
        drinkName: _nameCtrl.text.trim(),
        drinkType: _type.displayName,
      );

      // Parse basic sections from the AI response
      if (mounted) {
        setState(() {
          _recipeCtrl.text = result;
          // Try to extract a description from the first paragraph
          final lines = result.split('\n').where((l) => l.trim().isNotEmpty).toList();
          if (_descCtrl.text.isEmpty && lines.isNotEmpty) {
            _descCtrl.text = lines.first
                .replaceAll(RegExp(r'^#+\s*'), '')
                .replaceAll(RegExp(r'^\*+'), '')
                .trim();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }

    final drink = Drink(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      description: _descCtrl.text.trim(),
      ingredients: List.from(_ingredients),
      recipe: _recipeCtrl.text.trim(),
      isPopular: _isPopular,
      createdBy: widget.bartenderId,
    );

    context.read<DrinkProvider>().addDrink(drink);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drink.name} added to menu!'),
        backgroundColor: const Color(0xFF7B1FA2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🍹',
                      style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text(
                    'Add New Drink',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type selector
              Row(
                children: [
                  _TypeButton(
                    label: '🍸 Cocktail',
                    selected: _type == DrinkType.cocktail,
                    onTap: () => setState(() => _type = DrinkType.cocktail),
                  ),
                  const SizedBox(width: 8),
                  _TypeButton(
                    label: '🥤 Mocktail',
                    selected: _type == DrinkType.mocktail,
                    onTap: () => setState(() => _type = DrinkType.mocktail),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name + AI generate
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _nameCtrl,
                      label: 'Drink Name *',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateWithAI,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('AI', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A148C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _field(
                controller: _descCtrl,
                label: 'Description *',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Ingredients
              const Text('Ingredients',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _field(
                        controller: _ingredientCtrl, label: 'Add ingredient'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add_circle,
                        color: Color(0xFFFFB300), size: 28),
                  ),
                ],
              ),
              if (_ingredients.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _ingredients
                      .asMap()
                      .entries
                      .map(
                        (e) => Chip(
                          label: Text(e.value,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                          backgroundColor: const Color(0xFF4A148C),
                          deleteIconColor: Colors.white70,
                          onDeleted: () =>
                              setState(() => _ingredients.removeAt(e.key)),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),

              _field(
                controller: _recipeCtrl,
                label: 'Recipe / Preparation *',
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Popular toggle
              Row(
                children: [
                  Switch(
                    value: _isPopular,
                    onChanged: (v) => setState(() => _isPopular = v),
                    activeThumbColor: const Color(0xFFFFB300),
                  ),
                  const Text('Mark as Popular',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B1FA2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add to Menu',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B1FA2)),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7B1FA2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF7B1FA2)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
