import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:harmoniq/gemini_api.dart'; // Importa tu archivo de claves API

/// Servicio para interactuar con la API de Google Gemini.
class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Envía un mensaje al modelo de Gemini y obtiene una respuesta.
  ///
  /// [chatHistory] es la conversación actual, en el formato de la API de Gemini.
  /// [generationConfig] (opcional) es una configuración para la generación del modelo,
  ///   incluyendo el responseMimeType y el responseSchema para respuestas estructuradas.
  /// Retorna el mapa de contenido completo de la respuesta del modelo (ej. {"parts": [{"text": "..."}]}),
  /// o un mapa de contenido con un mensaje de error si la llamada a la API falla o es bloqueada.
  Future<Map<String, dynamic>> sendMessage({
    required List<Map<String, dynamic>> chatHistory,
    Map<String, dynamic>? generationConfig, // Nuevo parámetro opcional
  }) async {
    if (ApiKeys.geminiApiKey == 'TU_CLAVE_API_DE_GOOGLE_GEMINI_AQUI' || ApiKeys.geminiApiKey.isEmpty) {
      // Devolver un error formateado como respuesta de contenido.
      return {'parts': [{'text': 'Error: La clave API de Gemini no ha sido configurada. Reemplaza el placeholder en lib/config/api_keys.dart'}]};
    }

    final Map<String, dynamic> payload = {
      'contents': chatHistory,
    };

    // Añadir generationConfig al payload si se proporciona
    if (generationConfig != null) {
      payload['generationConfig'] = generationConfig;
    }

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
            result['candidates'][0]['content'] != null) {
          // Retorna el mapa de contenido completo del primer candidato
          return result['candidates'][0]['content'];
        } else if (result['promptFeedback'] != null && result['promptFeedback']['blockReason'] != null) {
          // Si la respuesta es bloqueada por seguridad.
          return {'parts': [{'text': 'Lo siento, no puedo responder a eso. Razón: ${result['promptFeedback']['blockReason']}'}]};
        }
        // En caso de que no haya candidato ni bloqueo, o el contenido sea nulo.
        return {'parts': [{'text': 'No pude generar una respuesta clara.'}]};

      } else {
        // En caso de error HTTP.
        print('Error en la API de Gemini: ${response.statusCode} - ${response.body}');
        return {'parts': [{'text': 'Error al comunicarse con la IA: ${response.statusCode}. Inténtalo de nuevo.'}]};
      }
    } catch (e) {
      // En caso de error de conexión.
      print('Error de conexión con la API de Gemini: $e');
      return {'parts': [{'text': 'Error de conexión. Asegúrate de tener acceso a internet y una clave API válida.'}]};
    }
  }
}
