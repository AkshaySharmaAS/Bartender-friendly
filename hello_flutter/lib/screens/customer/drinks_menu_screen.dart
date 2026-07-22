import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/drink.dart';
import '../../providers/drink_provider.dart';
import '../../widgets/drink_card.dart';
import '../../widgets/drink_detail_sheet.dart';

class DrinksMenuScreen extends StatefulWidget {
  const DrinksMenuScreen({super.key});

  @override
  State<DrinksMenuScreen> createState() => _DrinksMenuScreenState();
}

class _DrinksMenuScreenState extends State<DrinksMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

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
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            style: TextStyle(color: cs.onSurface),
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search drinks...',
              prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.4)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: cs.onSurface.withValues(alpha: 0.4)),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Tabs (hidden when searching)
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
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7B1FA2)),
                );
              }

              if (_searchQuery.isNotEmpty) {
                final results = provider.search(_searchQuery);
                return _DrinkGrid(
                  drinks: results,
                  emptyMessage: 'No drinks match "$_searchQuery"',
                );
              }

              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _DrinkGrid(drinks: provider.drinks),
                  _DrinkGrid(
                      drinks: provider.cocktails,
                      emptyMessage: 'No cocktails yet'),
                  _DrinkGrid(
                      drinks: provider.mocktails,
                      emptyMessage: 'No mocktails yet'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DrinkGrid extends StatelessWidget {
  final List<Drink> drinks;
  final String emptyMessage;

  const _DrinkGrid({
    required this.drinks,
    this.emptyMessage = 'No drinks available',
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: drinks.length,
      itemBuilder: (context, i) => DrinkCard(
        drink: drinks[i],
        onTap: () => DrinkDetailSheet.show(context, drinks[i]),
      ),
    );
  }
}
