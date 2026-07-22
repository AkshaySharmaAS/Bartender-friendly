import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/drink.dart';
import '../../providers/drink_provider.dart';
import '../../widgets/add_drink_dialog.dart';
import '../../widgets/drink_card.dart';
import '../../widgets/drink_detail_sheet.dart';

class AdminDrinksScreen extends StatefulWidget {
  const AdminDrinksScreen({super.key});

  @override
  State<AdminDrinksScreen> createState() => _AdminDrinksScreenState();
}

class _AdminDrinksScreenState extends State<AdminDrinksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Drink drink) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Drink',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${drink.name}" from the menu?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DrinkProvider>().removeDrink(drink.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${drink.name} removed.'),
                  backgroundColor: Colors.red.shade800,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search drinks...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.white38),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_searchQuery.isEmpty)
            TabBar(
              controller: _tabCtrl,
              indicatorColor: const Color(0xFFFFB300),
              labelColor: const Color(0xFFFFB300),
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: '🍸 Cocktails'),
                Tab(text: '🥤 Mocktails'),
              ],
            ),
          Expanded(
            child: Consumer<DrinkProvider>(
              builder: (context, provider, _) {
                if (_searchQuery.isNotEmpty) {
                  final results = provider.search(_searchQuery);
                  return _DrinkGrid(
                    drinks: results,
                    onDelete: (d) => _confirmDelete(context, d),
                    onTap: (d) => DrinkDetailSheet.show(context, d),
                    emptyMessage: 'No drinks match "$_searchQuery"',
                  );
                }

                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _DrinkGrid(
                        drinks: provider.drinks,
                        onDelete: (d) => _confirmDelete(context, d),
                        onTap: (d) => DrinkDetailSheet.show(context, d)),
                    _DrinkGrid(
                        drinks: provider.cocktails,
                        onDelete: (d) => _confirmDelete(context, d),
                        onTap: (d) => DrinkDetailSheet.show(context, d),
                        emptyMessage: 'No cocktails'),
                    _DrinkGrid(
                        drinks: provider.mocktails,
                        onDelete: (d) => _confirmDelete(context, d),
                        onTap: (d) => DrinkDetailSheet.show(context, d),
                        emptyMessage: 'No mocktails'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddDrinkDialog.show(context),
        backgroundColor: const Color(0xFF7B1FA2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Drink',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _DrinkGrid extends StatelessWidget {
  final List<Drink> drinks;
  final void Function(Drink) onDelete;
  final void Function(Drink) onTap;
  final String emptyMessage;

  const _DrinkGrid({
    required this.drinks,
    required this.onDelete,
    required this.onTap,
    this.emptyMessage = 'No drinks',
  });

  @override
  Widget build(BuildContext context) {
    if (drinks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍷', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: drinks.length,
      itemBuilder: (context, i) => DrinkCard(
        drink: drinks[i],
        showDeleteButton: true,
        onDelete: () => onDelete(drinks[i]),
        onTap: () => onTap(drinks[i]),
      ),
    );
  }
}
