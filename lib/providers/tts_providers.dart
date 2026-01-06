// import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tts_service.dart';

// Provider for the API Service
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

// State class for the TTS Module
class TtsState {
  final bool isLoading;
  final PlatformFile? referenceAudio;
  final String? selectedVoiceId;
  final double speed;
  final double intensity;
  final String? errorMessage;

  TtsState({
    this.isLoading = false,
    this.referenceAudio,
    this.selectedVoiceId,
    this.speed = 1.0,
    this.intensity = 0.5,
    this.errorMessage,
  });

  TtsState copyWith({
    bool? isLoading,
    PlatformFile? referenceAudio,
    String? selectedVoiceId,
    double? speed,
    double? intensity,
    String? errorMessage,
  }) {
    return TtsState(
      isLoading: isLoading ?? this.isLoading,
      referenceAudio: referenceAudio ?? this.referenceAudio,
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      speed: speed ?? this.speed,
      intensity: intensity ?? this.intensity,
      errorMessage: errorMessage,
    );
  }
}

// ViewModel / Controller for the TTS Screen
class TtsController extends StateNotifier<TtsState> {
  final TtsService _ttsService;

  TtsController(this._ttsService) : super(TtsState());

  void setSpeed(double value) {
    state = state.copyWith(speed: value);
  }

  void setIntensity(double value) {
    state = state.copyWith(intensity: value);
  }

  void setReferenceAudio(PlatformFile file) {
    state = state.copyWith(referenceAudio: file, selectedVoiceId: null);
  }

  void setSelectedVoiceId(String? voiceId) {
    state = state.copyWith(selectedVoiceId: voiceId, referenceAudio: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
  
  void setError(String message) {
     state = state.copyWith(errorMessage: message);
  }
  
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final ttsControllerProvider = StateNotifierProvider<TtsController, TtsState>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return TtsController(ttsService);
});
