import os
import asyncio
import torch
import torchaudio
try:
    torchaudio.set_audio_backend("soundfile")
except:
    pass
from TTS.api import TTS

class TTSEngine:
    def __init__(self):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.tts = None
        self.is_loading = False
        self.model_loaded = False
        
        # Demo Voices Map (Place .wav files in backend/voices/)
        self.demo_voices = {
            "sophia": "voices/sophia.wav",
            "ethan": "voices/ethan.wav",
            "lily": "voices/lily.wav",
            "jack": "voices/jack.wav"
        }

    async def load_model(self):
        """Loads the model asynchronously."""
        if self.model_loaded or self.is_loading:
            return
            
        self.is_loading = True
        print(f"Initializing TTS Engine on {self.device}...")
        
        try:
            # We must run this in a thread as it's blocking
            def _load():
                return TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(self.device)
            
            # Note: XTTS requires agreeing to terms. 
            # We can set an env var or pass it if the API supports it.
            # Coqui TTS usually looks for TTS_AGREEMENT=1 environment variable.
            os.environ["TTS_AGREEMENT"] = "1"
            
            self.tts = await asyncio.to_thread(_load)
            self.model_loaded = True
            print("TTS Model Loaded successfully")
        except Exception as e:
            print(f"Error loading model: {e}")
            self.tts = None
        finally:
            self.is_loading = False

    async def generate(self, text: str, output_path: str, reference_audio_path: str = None, voice_id: str = None, speed: float = 1.0, intensity: float = 0.5):
        """
        Generates speech using either a provided reference audio file or a demo voice ID.
        """
        if self.tts is None:
            print("TTS Model not loaded. Falling back to Mock.")
            return await self._mock_generate(output_path)

        try:
            # 1. Determine speaker source
            speaker_wav = None
            if voice_id and voice_id in self.demo_voices:
                speaker_wav = self.demo_voices[voice_id]
                # Check if demo file exists, if not fallback to reference if provided
                if not os.path.exists(speaker_wav):
                    print(f"Demo voice {voice_id} file not found at {speaker_wav}")
                    speaker_wav = reference_audio_path
            else:
                speaker_wav = reference_audio_path

            if not speaker_wav or not os.path.exists(speaker_wav):
                print("No valid speaker source found")
                return False

            # 2. Run Inference in a thread to not block FastAPI
            print(f"Synthesizing with speaker: {speaker_wav}")
            
            # XTTS supports speed directly in some versions or via post-processing
            # For now we use the basic API call
            await asyncio.to_thread(
                self.tts.tts_to_file,
                text=text,
                speaker_wav=speaker_wav,
                language="en",
                file_path=output_path
            )
            
            return True

        except Exception as e:
            import traceback
            print(f"Synthesis Error: {e}")
            traceback.print_exc()
            return False

    async def _mock_generate(self, output_path):
        # Fallback if model fails to load
        import shutil
        await asyncio.sleep(1)
        # Just create an empty/dummy file or copy some assets
        return False
