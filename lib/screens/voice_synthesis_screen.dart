// import 'dart:io'; // Removed for Web compatibility
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Removed
import 'package:google_fonts/google_fonts.dart';
import '../providers/tts_providers.dart';
import '../widgets/audio_waveform.dart';

class VoiceSynthesisScreen extends ConsumerStatefulWidget {
  const VoiceSynthesisScreen({super.key});

  @override
  ConsumerState<VoiceSynthesisScreen> createState() => _VoiceSynthesisScreenState();
}

class _VoiceSynthesisScreenState extends ConsumerState<VoiceSynthesisScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _textController = TextEditingController(
    text: "Hello, this is a test of my new voice.",
  );
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickReferenceAudio() async {
    ref.read(ttsControllerProvider.notifier).clearError();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // Needed for Web to get bytes
    );

    if (result != null) {
      final file = result.files.single;
      ref.read(ttsControllerProvider.notifier).setReferenceAudio(file);
    }
  }

  Future<void> _handleSynthesize() async {
    final state = ref.read(ttsControllerProvider);
    final notifier = ref.read(ttsControllerProvider.notifier);
    
    if (state.referenceAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a Reference Audio file first.")));
      return;
    }
    if (_textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter some text to synthesize.")));
      return;
    }

    notifier.setLoading(true);
    notifier.clearError();

    try {
      final service = ref.read(ttsServiceProvider);
      final audioBytes = await service.synthesizeSpeech(
        text: _textController.text,
        referenceAudio: state.referenceAudio!,
        speed: state.speed,
        intensity: state.intensity,
      );

      if (audioBytes != null) {
        await _audioPlayer.play(BytesSource(audioBytes));
      }

    } catch (e) {
      notifier.setError(e.toString());
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      notifier.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ttsState = ref.watch(ttsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE), // Cream
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 14,
              backgroundImage: const AssetImage('assets/images/logo_v2.png'),
            ),
            const SizedBox(width: 12),
            Text(
              "True Tone", 
              style: GoogleFonts.outfit(
                color: const Color(0xFF850E35), // Burgundy
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0.5), 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF850E35)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Text Display Area
            _buildSectionHeader("Input Text"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC4C4)), // Light Pink Border
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEE6983).withOpacity(0.1), 
                    blurRadius: 15, 
                    offset: const Offset(0, 5)
                  )
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                style: GoogleFonts.sourceCodePro(color: const Color(0xFF850E35), fontSize: 16, height: 1.5), 
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Waiting for sign language input...",
                  hintStyle: GoogleFonts.sourceCodePro(color: const Color(0xFF850E35).withOpacity(0.4)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. Reference Audio Picker
             _buildSectionHeader("Voice Identity"),
             const SizedBox(height: 10),
            
            GestureDetector(
              onTap: _pickReferenceAudio,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF850E35), // Burgundy
                      const Color(0xFF850E35).withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF850E35).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Row(
                  children: [
                     Container(
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.2), 
                         borderRadius: BorderRadius.circular(12)
                       ),
                       child: Icon(
                        Icons.graphic_eq,
                        color: ttsState.referenceAudio != null ? const Color(0xFFFFC4C4) : Colors.white,
                      ),
                     ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ttsState.referenceAudio != null ? "Voice Profile Active" : "Select Voice Profile",
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          if (ttsState.referenceAudio != null)
                             Text(
                              ttsState.referenceAudio!.name,
                              style: GoogleFonts.outfit(color: const Color(0xFFFFC4C4), fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.folder_open, color: Colors.white70),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),

            // 3. Emotion Controls
             _buildSectionHeader("Emotion Mapping"),
             const SizedBox(height: 15),
             
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEE6983).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(color: const Color(0xFFFFC4C4).withOpacity(0.5)),
               ),
               child: Column(
                 children: [
                    // Speed Slider
                    _buildControlRow(
                      context, 
                      "Speed", 
                      "${ttsState.speed.toStringAsFixed(1)}x", 
                      ttsState.speed, 
                      0.5, 
                      2.0, 
                      15,
                      const Color(0xFFEE6983), // Rose Pink
                      (val) => ref.read(ttsControllerProvider.notifier).setSpeed(val)
                    ),
                    
                    const SizedBox(height: 25),
                    Divider(color: const Color(0xFF850E35).withOpacity(0.1), height: 1),
                    const SizedBox(height: 25),

                    // Intensity Slider
                    _buildControlRow(
                      context, 
                      "Intensity", 
                      "${(ttsState.intensity * 100).toInt()}%", 
                      ttsState.intensity, 
                      0.0, 
                      1.0, 
                      10,
                      const Color(0xFF850E35), // Burgundy
                      (val) => ref.read(ttsControllerProvider.notifier).setIntensity(val)
                    ),
                 ],
               ),
             ),

            const SizedBox(height: 40),

            // 3.5 Audio Waveform (Visualizer)
            Center(
              child: AudioWaveform(
                isPlaying: _isPlaying,
                color: const Color(0xFFEE6983),
              ),
            ),

            const SizedBox(height: 30),

            // 4. Action Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEE6983).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: ElevatedButton(
                onPressed: ttsState.isLoading ? null : _handleSynthesize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE6983), // Rose Pink
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0, 
                ),
                child: ttsState.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mic, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            "GENERATE VOICE",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: const Color(0xFF850E35).withOpacity(0.6),
          fontSize: 12,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildControlRow(BuildContext context, String label, String valueDisplay, double value, double min, double max, int divisions, Color color, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.outfit(color: const Color(0xFF850E35), fontSize: 16, fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                valueDisplay,
                style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
