enum DrinkType { cocktail, mocktail }

extension DrinkTypeExtension on DrinkType {
  String get displayName =>
      this == DrinkType.cocktail ? 'Cocktail' : 'Mocktail';
}

class Drink {
  final String id;
  final String name;
  final DrinkType type;
  final String description;
  final List<String> ingredients;
  final String recipe;
  final bool isPopular;
  final String? imageUrl;
  final String? createdBy;
  final DateTime createdAt;

  Drink({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.ingredients,
    required this.recipe,
    this.isPopular = false,
    this.imageUrl,
    this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'description': description,
        'ingredients': ingredients,
        'recipe': recipe,
        'isPopular': isPopular,
        'imageUrl': imageUrl,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Drink.fromJson(Map<String, dynamic> json) => Drink(
        id: json['id'] as String,
        name: json['name'] as String,
        type: DrinkType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => DrinkType.cocktail,
        ),
        description: json['description'] as String,
        ingredients: List<String>.from(json['ingredients'] as List),
        recipe: json['recipe'] as String,
        isPopular: json['isPopular'] as bool? ?? false,
        imageUrl: json['imageUrl'] as String?,
        createdBy: json['createdBy'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Drink copyWith({
    String? id,
    String? name,
    DrinkType? type,
    String? description,
    List<String>? ingredients,
    String? recipe,
    bool? isPopular,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
  }) =>
      Drink(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        description: description ?? this.description,
        ingredients: ingredients ?? this.ingredients,
        recipe: recipe ?? this.recipe,
        isPopular: isPopular ?? this.isPopular,
        imageUrl: imageUrl ?? this.imageUrl,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );
}
