import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  final String _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _googleCloudApiKey = dotenv.env['GOOGLE_CLOUD_API_KEY'] ?? '';

  // Search by Name using Spoonacular
  Future<Map<String, dynamic>?> searchByName(String query) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'].isNotEmpty ? data['results'][0] : null;
    }
    return null;
  }

  // Search by Image using Google Cloud Vision API
  Future<Map<String, dynamic>?> searchByImage(File image) async {
    // Use Google Cloud Vision API to detect dish label
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

      // Extract the first detected label
      final labels = visionData['responses'][0]['labelAnnotations'];
      if (labels != null && labels.isNotEmpty) {
        final dishName = labels[0]['description'];

        // Search by Name using Spoonacular
        return await searchByName(dishName);
      }
    }
    return null;
  }
}
