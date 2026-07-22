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
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final bartenderId =
        context.watch<AuthProvider>().currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
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
                if (provider.isLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF7B1FA2)),
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
        backgroundColor: const Color(0xFF7B1FA2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Drink',
            style: TextStyle(color: Colors.white)),
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
            const SizedBox(height: 8),
            const Text('Tap + to add one!',
                style:
                    TextStyle(color: Colors.white38, fontSize: 12)),
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
