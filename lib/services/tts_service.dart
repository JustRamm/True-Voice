import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Add this
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class TtsService {
  final String _baseUrl;
  final Logger _logger = Logger();

  TtsService({String? baseUrl}) : _baseUrl = baseUrl ?? _getDefaultBaseUrl();

  static String _getDefaultBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000'; // iOS, Windows, macOS
  }

  Future<Uint8List?> synthesizeSpeech({
    required String text,
    PlatformFile? referenceAudio,
    String? voiceId,
    required double speed,
    required double intensity,
  }) async {
    final uri = Uri.parse('$_baseUrl/synthesize');
    
    try {
      var request = http.MultipartRequest('POST', uri);
      
      // Add fields
      request.fields['text'] = text;
      request.fields['speed'] = speed.toString();
      request.fields['intensity'] = intensity.toString();
      if (voiceId != null) {
        request.fields['voice_id'] = voiceId;
      }
 
      // Add file if provided
      if (referenceAudio != null) {
        if (kIsWeb) {
          if (referenceAudio.bytes != null) {
             request.files.add(http.MultipartFile.fromBytes(
              'reference_audio',
              referenceAudio.bytes!,
              filename: referenceAudio.name,
            ));
          }
        } else {
          if (referenceAudio.path != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'reference_audio',
              referenceAudio.path!,
            ));
          } else if (referenceAudio.bytes != null) {
             request.files.add(http.MultipartFile.fromBytes(
                'reference_audio',
                referenceAudio.bytes!,
                filename: referenceAudio.name,
              ));
          }
        }
      } else if (voiceId == null) {
          throw Exception('Either reference audio or a voice ID must be provided');
      }
 
      _logger.i('Sending TTS request: "$text" | Voice: ${voiceId ?? "Custom"}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Assuming the backend returns the audio bytes directly or Base64.
        // If "audio/wav" or binary:
        _logger.i('TTS generation successful. Received ${response.bodyBytes.lengthInBytes} bytes.');
        return response.bodyBytes;
        
        // If the backend returns JSON with base64, we would parse it here:
        // final data = jsonDecode(response.body);
        // return base64Decode(data['audio_content']);
      } else {
        _logger.e('TTS Request failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to synthesize speech: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error calling TTS service: $e');
      rethrow;
    }
  }
}
