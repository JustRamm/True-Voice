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
    required PlatformFile referenceAudio,
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

      // Add file
      if (kIsWeb) {
        if (referenceAudio.bytes != null) {
           request.files.add(http.MultipartFile.fromBytes(
            'reference_audio',
            referenceAudio.bytes!,
            filename: referenceAudio.name,
          ));
        } else {
             _logger.e('Audio bytes missing on web');
             throw Exception('Audio bytes missing on web selection');
        }
      } else {
        // Mobile/Desktop
        if (referenceAudio.path != null) {
          var audioFile = await http.MultipartFile.fromPath(
            'reference_audio',
            referenceAudio.path!,
          );
          request.files.add(audioFile);
        } else {
             // Fallback to bytes if path is null for some reason
             if (referenceAudio.bytes != null) {
                  request.files.add(http.MultipartFile.fromBytes(
                  'reference_audio',
                  referenceAudio.bytes!,
                  filename: referenceAudio.name,
                ));
             } else {
                  throw Exception('Audio file path and bytes are missing');
             }
        }
      }

      _logger.i('Sending TTS request: "$text" with speed $speed, intensity $intensity');
      
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
