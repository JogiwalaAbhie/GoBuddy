import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'itinerary_model.dart';

class GeminiApi {
  final String apiKey;
  final String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateText";


  GeminiApi(this.apiKey);

  Future<String> generateTripOverview(String destination, int days, String costLevel) async {
    String prompt = "Generate an overview for a trip to $destination for $days days with a $costLevel budget.";

    try {
      final response = await http.post(
        Uri.parse("$endpoint?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": {"text": prompt}
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response has expected structure
        if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['output'];
        } else {
          throw Exception("Unexpected API response structure");
        }
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("Error generating trip overview: $error");
      return "Trip overview could not be generated. Please try again later.";
    }
  }

  Future<int> calculateApproxRate(int days, String costLevel) async {
    String prompt = "Estimate the approximate cost for a $days-day trip with a $costLevel budget.";

    try {
      final response = await http.post(
        Uri.parse("$endpoint?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prompt": {"text": prompt}
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response has the expected structure
        if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['output'];
        } else {
          throw Exception("Unexpected API response structure: $data");
        }
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("Error estimating cost: $error");
      return 1000;
    }
  }

  Future<Itinerary?> generateItinerary(String userPrompt) async {
    final dio = Dio();
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=AIzaSyC_Fdxg404-NJbwkj5BPECWmuMmPDLKLZQ';

    final data = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": userPrompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 1,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 8192,
        "responseMimeType": "text/plain"
      }
    };

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        try {
          final itinerary = Itinerary.fromJson(response.data);
          return itinerary;
        } catch (e) {
          print('Error parsing JSON: $e');
          return null; // or throw an exception
        }
      } else {
        print('Error: ${response.statusCode} - ${response.data}');
        return null; // or throw an exception
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      return null; // or throw an exception
    } catch (e) {
      print('General Error: $e');
      return null; // or throw an exception
    }
  }
}
