import '../models/user.dart';
import '../models/drink.dart';

class SeedData {
  static List<User> get defaultUsers => [
        User(
          id: 'admin1',
          name: 'Admin',
          email: 'admin@bar.com',
          password: 'admin123',
          role: UserRole.admin,
        ),
        User(
          id: 'bart1',
          name: 'Jake Miller',
          email: 'bartender@bar.com',
          password: 'bar123',
          role: UserRole.bartender,
        ),
        User(
          id: 'cust1',
          name: 'Alex Johnson',
          email: 'customer@bar.com',
          password: 'cust123',
          role: UserRole.customer,
        ),
      ];

  static List<Drink> get popularDrinks => [
        // ── Cocktails ─────────────────────────────────────────────────────
        Drink(
          id: 'mojito',
          name: 'Mojito',
          type: DrinkType.cocktail,
          description:
              'A refreshing Cuban classic with bright citrus and cool mint.',
          ingredients: [
            '60ml white rum',
            '30ml fresh lime juice',
            '2 tsp cane sugar',
            '6–8 fresh mint leaves',
            'Soda water',
            'Ice',
          ],
          recipe:
              'Muddle mint leaves and sugar in a glass. Add lime juice and rum. Fill with ice and top with soda water. Stir gently. Garnish with mint sprig and lime wheel.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'margarita',
          name: 'Margarita',
          type: DrinkType.cocktail,
          description:
              'The iconic tequila cocktail — tangy, bright and perfectly balanced.',
          ingredients: [
            '60ml tequila blanco',
            '30ml triple sec (Cointreau)',
            '30ml fresh lime juice',
            'Salt for rim',
            'Ice',
          ],
          recipe:
              'Rim glass with salt. Combine tequila, triple sec and lime juice in a shaker with ice. Shake well and strain into prepared glass over fresh ice. Garnish with lime wheel.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'old_fashioned',
          name: 'Old Fashioned',
          type: DrinkType.cocktail,
          description:
              'A timeless whiskey cocktail — smooth, rich and effortlessly sophisticated.',
          ingredients: [
            '60ml bourbon or rye whiskey',
            '1 sugar cube (or 1 tsp sugar)',
            '2 dashes Angostura bitters',
            'Orange peel',
            'Ice',
          ],
          recipe:
              'Place sugar cube in glass and saturate with bitters. Add a splash of water and muddle. Fill glass with large ice cubes. Pour whiskey over ice. Stir for 30 seconds. Express orange peel over glass and use as garnish.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'martini',
          name: 'Classic Martini',
          type: DrinkType.cocktail,
          description:
              'Elegance in a glass — crisp, clean and endlessly customisable.',
          ingredients: [
            '75ml London dry gin',
            '15ml dry vermouth',
            'Green olive or lemon twist',
            'Ice',
          ],
          recipe:
              'Add gin and vermouth to a mixing glass with ice. Stir for 30–40 seconds until well chilled. Strain into a chilled martini glass. Garnish with olive or lemon twist.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'cosmopolitan',
          name: 'Cosmopolitan',
          type: DrinkType.cocktail,
          description:
              'Chic and vibrant — a pink cocktail with citrus punch and cranberry elegance.',
          ingredients: [
            '45ml citrus vodka',
            '15ml triple sec',
            '30ml cranberry juice',
            '15ml fresh lime juice',
            'Ice',
          ],
          recipe:
              'Combine all ingredients in a shaker with ice. Shake vigorously for 15 seconds. Strain into a chilled martini glass. Garnish with orange twist flamed over the glass.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'negroni',
          name: 'Negroni',
          type: DrinkType.cocktail,
          description:
              'Bold, bitter and beautiful — Italy\'s most beloved aperitivo cocktail.',
          ingredients: [
            '30ml gin',
            '30ml Campari',
            '30ml sweet vermouth',
            'Orange peel',
            'Ice',
          ],
          recipe:
              'Add all ingredients to a mixing glass with ice. Stir for 30 seconds. Strain into a rocks glass over a large ice cube. Garnish with an orange peel expressed over the glass.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'pina_colada',
          name: 'Piña Colada',
          type: DrinkType.cocktail,
          description:
              'A tropical paradise in a glass — creamy, sweet and endlessly refreshing.',
          ingredients: [
            '60ml white rum',
            '60ml coconut cream',
            '90ml pineapple juice',
            'Crushed ice',
            'Pineapple slice and cherry to garnish',
          ],
          recipe:
              'Blend rum, coconut cream, and pineapple juice with crushed ice until smooth. Pour into a chilled glass. Garnish with pineapple slice and maraschino cherry.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'daiquiri',
          name: 'Daiquiri',
          type: DrinkType.cocktail,
          description:
              'Simple perfection — rum, citrus and sugar in elegant harmony.',
          ingredients: [
            '60ml white rum',
            '30ml fresh lime juice',
            '15ml simple syrup',
            'Ice',
          ],
          recipe:
              'Combine all ingredients in a cocktail shaker with ice. Shake vigorously for 15 seconds. Double strain into a chilled coupe glass. Garnish with a lime wheel.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        // ── Mocktails ─────────────────────────────────────────────────────
        Drink(
          id: 'virgin_mojito',
          name: 'Virgin Mojito',
          type: DrinkType.mocktail,
          description:
              'All the refreshing zest of a mojito, without the alcohol.',
          ingredients: [
            '30ml fresh lime juice',
            '2 tsp sugar',
            '8 fresh mint leaves',
            'Soda water',
            'Ice',
          ],
          recipe:
              'Muddle mint and sugar in a glass. Add lime juice and ice. Top with soda water. Stir gently. Garnish with a mint sprig and lime wheel.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'shirley_temple',
          name: 'Shirley Temple',
          type: DrinkType.mocktail,
          description:
              'A beloved classic — sweet, fizzy and fun for all ages.',
          ingredients: [
            '120ml ginger ale',
            '60ml orange juice',
            '30ml grenadine',
            'Maraschino cherry',
            'Orange slice',
          ],
          recipe:
              'Fill a glass with ice. Add orange juice and ginger ale. Slowly pour grenadine over the back of a spoon for a sunrise effect. Garnish with cherry and orange slice.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'arnold_palmer',
          name: 'Arnold Palmer',
          type: DrinkType.mocktail,
          description:
              'The legendary half-and-half — iced tea meets lemonade in perfect balance.',
          ingredients: [
            '120ml freshly brewed iced tea (cooled)',
            '120ml lemonade',
            'Lemon slice',
            'Ice',
          ],
          recipe:
              'Fill a tall glass with ice. Pour iced tea and lemonade in equal parts. Stir gently. Garnish with a lemon slice.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
        Drink(
          id: 'tropical_sunrise',
          name: 'Tropical Sunrise',
          type: DrinkType.mocktail,
          description:
              'A vibrant tropical mocktail bursting with sunshine flavours.',
          ingredients: [
            '90ml orange juice',
            '60ml pineapple juice',
            '30ml mango nectar',
            '15ml grenadine',
            'Ice',
          ],
          recipe:
              'Pour orange juice, pineapple juice and mango nectar over ice in a tall glass. Slowly drizzle grenadine down the side of the glass. Garnish with a pineapple wedge and cherry.',
          isPopular: true,
          createdBy: 'bart1',
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
}
