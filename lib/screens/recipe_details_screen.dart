import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final recipeData = args?['recipeData'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
      body: recipeData != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipeData['name'] ?? 'Unknown Dish',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...List<Widget>.from(
              (recipeData['ingredients'] as List).map(
                    (ingredient) => Text('• $ingredient'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(recipeData['instructions'] ?? 'No instructions available.'),
          ],
        ),
      )
          : const Center(
        child: Text('No recipe data found.'),
      ),
    );
  }
}
