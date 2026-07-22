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
        title: const Text('Remove Drink'),
        content: Text('Remove "${drink.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DrinkProvider>().removeDrink(drink.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${drink.name} removed.')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remove'),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search drinks...',
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
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
        icon: const Icon(Icons.add),
        label: const Text('Add Drink'),
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
    final cs = Theme.of(context).colorScheme;

    if (drinks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍷', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 14)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 500 ? 2 : constraints.maxWidth < 800 ? 3 : 4;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          itemCount: drinks.length,
          itemBuilder: (context, i) => DrinkCard(
            drink: drinks[i],
            showDeleteButton: true,
            onDelete: () => onDelete(drinks[i]),
            onTap: () => onTap(drinks[i]),
          ),
        );
      },
    );
  }
}
