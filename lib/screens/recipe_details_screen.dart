import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? recipes;
  final Set<Map<String, dynamic>>? favorites;
  final void Function(Map<String, dynamic>)? toggleFavorite;

  const RecipeDetailsScreen({
    super.key,
    this.recipes,
    this.favorites,
    this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        backgroundColor: Colors.lightBlue,
      ),
      body: recipes != null && recipes!.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: recipes!.length,
          itemBuilder: (context, index) {
            final recipe = recipes![index];
            final isFavorite = favorites?.contains(recipe) ?? false;
            final ingredients = recipe['ingredients'] as List<dynamic>? ?? [];
            final instructions = recipe['instructions'] ?? 'Instructions not available.';

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              recipe['title'] ?? 'Unknown Dish',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          recipe['image'] != null && recipe['image'].isNotEmpty
                              ? Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                recipe['image'],
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 100,
                                    color: Colors.red,
                                  );
                                },
                              ),
                            ),
                          )
                              : const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Ingredients:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ingredients.isNotEmpty
                              ? Column(
                            children: ingredients.map((ingredient) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                              : const Text(
                            'No ingredients available.',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Instructions:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            instructions,
                            style: const TextStyle(fontSize: 18, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.yellow : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () => toggleFavorite?.call(recipe),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      )
          : const Center(
        child: Text(
          'No recipe data found.',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
}
