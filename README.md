# True Voice 🎙️

True Voice is a premium AI-powered Voice Synthesis and Cloning application built with Flutter. It allows users to create high-fidelity voice clones from short audio samples and synthesize text into speech with emotional nuance.

## ✨ Features

- **Premium UI/UX**: A sophisticated, warm aesthetic using a Cream, Burgundy, and Rose Pink color palette.
- **AI Voice Cloning**: Synthesize speech using a reference audio profile.
- **Emotion Mapping**: Adjust speed and intensity to match the desired emotional tone.
- **Audio Visualization**: Real-time waveform animation during playback for immersive feedback.
- **Secure Flow**: Professional Splash, Login, and Signup screens.
- **Cross-Platform**: Designed to work on Web, Android, iOS, and Desktop.

## 🎨 Design System

- **Primary Color**: Burgundy (`#850E35`)
- **Secondary Color**: Rose Pink (`#EE6983`)
- **Background**: Cream (`#FCF5EE`)
- **Typography**: Outfit (Google Fonts)

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started)
- A backend server running the [True Voice AI API](https://github.com/JustRamm/True-Voice-Backend) (default: `localhost:8000`)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/JustRamm/True-Voice.git
   cd True-Voice
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   # For Chrome
   flutter run -d chrome

   # For Mobile
   flutter run
   ```

## 🛠️ Project Structure

- `lib/screens/`: UI screens (Home, Profile, Messages, Auth).
- `lib/services/`: API integration services.
- `lib/providers/`: State management using Riverpod.
- `lib/widgets/`: Reusable UI components (Waveform, Custom Buttons).

## 📡 Backend Integration

The app is configured to communicate with a Multi-lingual TTS backend. 
Update the base URL in `lib/services/tts_service.dart` if your server is hosted remotely.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
