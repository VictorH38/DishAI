import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final recipeData = args?['recipeData'];
    final ingredients = recipeData?['ingredients'] as List<dynamic>? ?? [];
    final instructions = recipeData?['instructions'] ?? 'Instructions not available.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        backgroundColor: Colors.lightBlue,
      ),
      body: recipeData != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  recipeData['title'] ?? 'Unknown Dish',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              recipeData['image'] != null
                  ? Center(
                child: Image.network(
                  recipeData['image'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
                  : const SizedBox.shrink(),
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
