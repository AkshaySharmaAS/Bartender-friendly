import 'package:flutter/material.dart';
import '../models/drink.dart';

class DrinkCard extends StatelessWidget {
  final Drink drink;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showDeleteButton;

  const DrinkCard({
    super.key,
    required this.drink,
    this.onDelete,
    this.onTap,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCocktail = drink.type == DrinkType.cocktail;
    final accentColor = isCocktail ? cs.secondary : cs.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: cs.outline.withValues(alpha: 0.4), width: 0.5)
              : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Photo area ─────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(isDark, cs, accentColor, isCocktail),
                    // Popular badge
                    if (drink.isPopular)
                      Positioned(
                        top: 7,
                        left: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 9, color: Color(0xFFFFD700)),
                              SizedBox(width: 3),
                              Text('Popular',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    // Delete button
                    if (showDeleteButton && onDelete != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Name & type ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(
                            alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        drink.type.displayName,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(
      bool isDark, ColorScheme cs, Color accentColor, bool isCocktail) {
    if (drink.imageUrl != null && drink.imageUrl!.isNotEmpty) {
      return Image.network(
        drink.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(isDark, cs, accentColor, isCocktail,
              loading: true);
        },
        errorBuilder: (context, _, __) =>
            _placeholder(isDark, cs, accentColor, isCocktail),
      );
    }
    return _placeholder(isDark, cs, accentColor, isCocktail);
  }

  Widget _placeholder(bool isDark, ColorScheme cs, Color accentColor,
      bool isCocktail, {bool loading = false}) {
    return Container(
      color: isDark
          ? cs.surfaceVariant
          : accentColor.withValues(alpha: 0.07),
      child: Center(
        child: loading
            ? CircularProgressIndicator(
                color: accentColor, strokeWidth: 1.5)
            : Text(
                isCocktail ? '🍸' : '🥤',
                style: const TextStyle(fontSize: 42),
              ),
      ),
    );
  }
}