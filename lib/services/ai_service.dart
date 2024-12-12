import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class AIService {
  final String _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _googleCloudApiKey = dotenv.env['GOOGLE_CLOUD_API_KEY'] ?? '';

  // Search by Name using Spoonacular
  Future<List<Map<String, dynamic>>> searchByName(String query) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey&instructionsRequired=true&addRecipeInformation=true&fillIngredients=true'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] != null && data['results'] is List) {
        final filteredResults = (data['results'] as List).where((result) {
          final ingredients = result['extendedIngredients'];
          final instructions = result['analyzedInstructions'];
          return ingredients != null &&
              ingredients.isNotEmpty &&
              instructions != null &&
              instructions.isNotEmpty;
        }).map((result) {
          final formattedIngredients = (result['extendedIngredients'] as List)
              .map((ingredient) =>
          '${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}')
              .toList();

          final instructionSteps = (result['analyzedInstructions'][0]['steps'] as List)
              .map((step) => '• ${step['step']}')
              .join('\n');

          return {
            'id': result['id'],
            'title': result['title'],
            'image': result['image'],
            'ingredients': formattedIngredients,
            'instructions': instructionSteps,
          };
        }).toList();

        return filteredResults;
      }
    }
    return [];
  }

  // Search by Image using Google Cloud Vision API
  Future<List<Map<String, dynamic>>> searchByImage(XFile image) async {
    try {
      final visionUrl = 'https://vision.googleapis.com/v1/images:annotate?key=$_googleCloudApiKey';
      final base64Image = base64Encode(await image.readAsBytes());

      final requestPayload = {
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {"type": "LABEL_DETECTION", "maxResults": 5}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(visionUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final visionData = jsonDecode(response.body);
        final labels = visionData['responses'][0]['labelAnnotations'];

        if (labels != null && labels.isNotEmpty) {
          // Call ChatGPT to determine the dish
          final dishName = await getDishFromLabels(labels);
          print('dish name: $dishName');
          final List<Map<String, dynamic>> searchResults = await searchByName(dishName);
          return searchResults;
        }
      } else {
        throw Exception('Failed to fetch data from Vision API.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in searchByImage: $e');
      }
    }
    return [];
  }

  // Call ChatGPT for dish prediction
  Future<String> getDishFromLabels(List<Map<String, dynamic>> labels) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    const openAiUrl = 'https://api.openai.com/v1/completions';

    // Format the labels as a text description
    final labelDescriptions = labels.map((label) => label['description']).join(', ');

    // Request payload for ChatGPT
    final requestPayload = {
      "model": "text-davinci-003",
      "prompt": "Based on the following labels: $labelDescriptions, what food dish is most likely being described?",
      "max_tokens": 50,
      "temperature": 0.5,
    };

    try {
      final response = await http.post(
        Uri.parse(openAiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dishName = data['choices'][0]['text'].trim();
        return dishName;
      } else {
        throw Exception('Failed to call OpenAI API: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getDishFromLabels: $e');
      }
      return "Unknown Dish";
    }
  }
}
