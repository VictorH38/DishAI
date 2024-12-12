import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
        final filteredResults = (data['results'] as List<dynamic>).where((result) {
          final ingredients = result['extendedIngredients'];
          final instructions = result['analyzedInstructions'];
          return ingredients != null &&
              ingredients.isNotEmpty &&
              instructions != null &&
              instructions.isNotEmpty;
        }).map((result) {
          final formattedIngredients = (result['extendedIngredients'] as List<dynamic>)
              .map((ingredient) =>
          '${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}')
              .toList();

          final instructionSteps = (result['analyzedInstructions'][0]['steps'] as List<dynamic>)
              .map((step) => '• ${step['step']}')
              .join('\n');

          return {
            'id': result['id'],
            'title': result['title'],
            'image': result['image'],
            'ingredients': formattedIngredients,
            'instructions': instructionSteps,
          };
        }).cast<Map<String, dynamic>>().toList();

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
              {"type": "LABEL_DETECTION", "maxResults": 10}
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
        final labels = List<Map<String, dynamic>>.from(visionData['responses'][0]['labelAnnotations'] ?? []);

        if (labels.isNotEmpty) {
          final dishName = await getDishFromLabelsAndImage(labels, base64Image);
          final searchResults = await searchByName(dishName);
          return searchResults.cast<Map<String, dynamic>>();
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
  Future<String> getDishFromLabelsAndImage(List<Map<String, dynamic>> labels, String base64Image) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    const openAiUrl = 'https://api.openai.com/v1/chat/completions';

    final labelDescriptions = labels.map((label) => label['description']).join(', ');

    final requestPayload = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "Based on the following image and labels, what food dish is most likely being described? Give me just the name of the dish.",
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:image/jpeg;base64,$base64Image",
              },
            },
            {
              "type": "text",
              "text": "Labels: $labelDescriptions",
            }
          ],
        },
      ],
      "max_tokens": 300,
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
        final dishName = data['choices'][0]['message']['content'].trim();
        return dishName;
      } else {
        throw Exception('Failed to call OpenAI API: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getDishFromLabelsAndImage: $e');
      }
      return "Unknown Dish";
    }
  }
}
