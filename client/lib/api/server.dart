import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getResponse(String text) async {
  try {
    final url = Uri.http("localhost:3000", "/api/search", {"text": text});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load data");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}
