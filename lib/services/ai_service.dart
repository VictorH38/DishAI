import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiBaseUrl = '';
  final String _apiKey = '';

  Future<Map<String, dynamic>?> searchByName(String query) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/searchByName'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> searchByImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_apiBaseUrl/searchByImage'),
    );

    request.headers['Authorization'] = 'Bearer $_apiKey';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    }
    return null;
  }
}
