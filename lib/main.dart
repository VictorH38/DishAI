import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_details_screen.dart';
import 'screens/favorites_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const DishAIApp());
}

class DishAIApp extends StatefulWidget {
  const DishAIApp({super.key});

  @override
  _DishAIAppState createState() => _DishAIAppState();
}

class _DishAIAppState extends State<DishAIApp> {
  // Manage the favorites as a Set to avoid duplicates
  final Set<Map<String, dynamic>> _favorites = {};

  void _toggleFavorite(Map<String, dynamic> recipe) {
    setState(() {
      if (_favorites.contains(recipe)) {
        _favorites.remove(recipe);
      } else {
        _favorites.add(recipe);
      }
    });
  }

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
        '/': (context) => HomeScreen(
          onNavigateToRecipeDetails: (recipes) {
            Navigator.pushNamed(context, '/recipeDetails', arguments: {
              'recipes': recipes,
              'favorites': _favorites,
              'toggleFavorite': _toggleFavorite,
            });
          },
        ),
        '/recipeDetails': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final recipes = arguments?['recipes'] as List<Map<String, dynamic>>?;
          final favorites = arguments?['favorites'] as Set<Map<String, dynamic>>?;
          final toggleFavorite = arguments?['toggleFavorite'] as void Function(Map<String, dynamic>)?;

          return RecipeDetailsScreen(
            recipes: recipes,
            favorites: favorites,
            toggleFavorite: toggleFavorite,
          );
        },
        '/favorites': (context) => FavoritesScreen(
          favorites: _favorites,
          toggleFavorite: _toggleFavorite,
        ),
      },
    );
  }
}
