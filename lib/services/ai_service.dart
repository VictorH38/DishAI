import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          // Check if both ingredients and instructions exist and are not empty
          final ingredients = result['extendedIngredients'];
          final instructions = result['analyzedInstructions'];
          return ingredients != null &&
              ingredients.isNotEmpty &&
              instructions != null &&
              instructions.isNotEmpty;
        }).map((result) {
          // Extract and format the instructions into a single string
          final instructionSteps = result['analyzedInstructions'][0]['steps']
              .map((step) => step['step'])
              .join('\n');

          return {
            'id': result['id'],
            'title': result['title'],
            'image': result['image'],
            'ingredients': result['extendedIngredients'],
            'instructions': instructionSteps,
          };
        }).toList();

        return filteredResults;
      }
    }

    return [];
  }

  // Search by Image using Google Cloud Vision API
  Future<List<Map<String, dynamic>>> searchByImage(File image) async {
    final visionUrl = 'https://vision.googleapis.com/v1/images:annotate?key=$_googleCloudApiKey';
    final base64Image = base64Encode(image.readAsBytesSync());
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
        final dishName = labels[0]['description'];
        return await searchByName(dishName);
      }
    }
    return [];
  }
}
