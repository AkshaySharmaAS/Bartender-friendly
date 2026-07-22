import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/drink.dart';
import '../../providers/auth_provider.dart';
import '../../providers/drink_provider.dart';
import '../../widgets/add_drink_dialog.dart';
import '../../widgets/drink_card.dart';
import '../../widgets/drink_detail_sheet.dart';

class ManageDrinksScreen extends StatefulWidget {
  const ManageDrinksScreen({super.key});

  @override
  State<ManageDrinksScreen> createState() => _ManageDrinksScreenState();
}

class _ManageDrinksScreenState extends State<ManageDrinksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrinkProvider>().loadDrinks();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bartenderId =
        context.watch<AuthProvider>().currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: '🍸 Cocktails'),
              Tab(text: '🥤 Mocktails'),
            ],
          ),
          Expanded(
            child: Consumer<DrinkProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary),
                  );
                }

                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _DrinkList(
                      drinks: provider.drinks,
                      onDelete: (d) => _confirmDelete(context, d),
                      onTap: (d) => DrinkDetailSheet.show(context, d),
                    ),
                    _DrinkList(
                      drinks: provider.cocktails,
                      onDelete: (d) => _confirmDelete(context, d),
                      onTap: (d) => DrinkDetailSheet.show(context, d),
                      emptyMessage: 'No cocktails yet',
                    ),
                    _DrinkList(
                      drinks: provider.mocktails,
                      onDelete: (d) => _confirmDelete(context, d),
                      onTap: (d) => DrinkDetailSheet.show(context, d),
                      emptyMessage: 'No mocktails yet',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            AddDrinkDialog.show(context, bartenderId: bartenderId),
        icon: const Icon(Icons.add),
        label: const Text('Add Drink'),
      ),
    );
  }
}

class _DrinkList extends StatelessWidget {
  final List<Drink> drinks;
  final void Function(Drink) onDelete;
  final void Function(Drink) onTap;
  final String emptyMessage;

  const _DrinkList({
    required this.drinks,
    required this.onDelete,
    required this.onTap,
    this.emptyMessage = 'No drinks yet',
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
            const SizedBox(height: 8),
            Text('Tap + to add one!',
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.35),
                    fontSize: 12)),
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
