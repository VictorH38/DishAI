import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_details_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  runApp(const DishAIApp());
}

class DishAIApp extends StatelessWidget {
  const DishAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        // '/recipeDetails': (context) => const RecipeDetailsScreen(),
        // '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
