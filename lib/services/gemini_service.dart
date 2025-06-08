import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:harmoniq/gemini_api.dart'; // Api key Import 

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Send a prompt to Gemini and get a response
  ///
  /// [chatHistory] is the actual conversation
  Future<String> sendMessage({required List<Map<String, dynamic>> chatHistory}) async {

    final payload = {
      'contents': chatHistory,
    };

    final uri = Uri.parse('$_baseUrl?key=${ApiKeys.geminiApiKey}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        
        if (result['candidates'] != null &&
            result['candidates'].isNotEmpty &&
            result['candidates'][0]['content'] != null &&
            result['candidates'][0]['content']['parts'] != null &&
            result['candidates'][0]['content']['parts'].isNotEmpty) {
          return result['candidates'][0]['content']['parts'][0]['text'] ?? 'No pude generar una respuesta.';
        } else if (result['promptFeedback'] != null && result['promptFeedback']['blockReason'] != null) {
          // When the answer is blocked
          return 'Lo siento, no puedo responder a eso. Razón: ${result['promptFeedback']['blockReason']}';
        }
        return 'No pude generar una respuesta clara.';

      } else {
        return 'Error al comunicarse con la IA: ${response.statusCode}. Inténtalo de nuevo.';
      }
    } catch (e) {
      return 'Error de conexión. Asegúrate de tener acceso a internet y una clave API válida.';
    }
  }
}
