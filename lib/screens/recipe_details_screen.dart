import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>>? recipes =
    ModalRoute.of(context)?.settings.arguments as List<Map<String, dynamic>>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        backgroundColor: Colors.lightBlue,
      ),
      body: recipes != null && recipes.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final ingredients = recipe['ingredients'] as List<dynamic>? ?? [];
            final instructions = recipe['instructions'] ?? 'Instructions not available.';

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
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
                          final name = ingredient['name'] ?? 'Unknown ingredient';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name,
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
              ),
            );
          },
        ),
      )
          : const Center(
        child: Text(
          'No recipe data found.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}
