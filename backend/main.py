from typing import Optional
import os
import shutil
import uuid
import uvicorn
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from tts_engine import TTSEngine

app = FastAPI(title="True Voice AI Backend")

# Enable CORS for Flutter Web compatibility
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize TTS Engine
tts_engine = TTSEngine()

@app.on_event("startup")
async def startup_event():
    # Start loading the model in the background
    import asyncio
    asyncio.create_task(tts_engine.load_model())

# Temporary directory for processing audio
UPLOAD_DIR = "temp_audio"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.get("/voices")
async def get_voices():
    """Returns the list of available demo voices."""
    return {"voices": list(tts_engine.demo_voices.keys())}

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "model_loaded": tts_engine.model_loaded,
        "is_loading": tts_engine.is_loading
    }

@app.post("/synthesize")
async def synthesize(
    text: str = Form(...),
    speed: float = Form(1.0),
    intensity: float = Form(0.5),
    voice_id: Optional[str] = Form(None),
    reference_audio: Optional[UploadFile] = File(None)
):
    """
    Endpoint to receive text and either a reference audio file or a voice_id.
    """
    if not tts_engine.model_loaded and not tts_engine.is_loading:
        # If model hasn't even started loading, try to trigger it
        import asyncio
        asyncio.create_task(tts_engine.load_model())
        raise HTTPException(status_code=503, detail="TTS Model is initializing. Please try again in a moment.")
    
    if tts_engine.is_loading:
        raise HTTPException(status_code=503, detail="TTS Model is still loading. Please wait.")

    try:
        session_id = str(uuid.uuid4())
        ref_path = None

        # 1. Handle Reference Audio if provided
        if reference_audio:
            ref_path = os.path.join(UPLOAD_DIR, f"ref_{session_id}_{reference_audio.filename}")
            with open(ref_path, "wb") as buffer:
                shutil.copyfileobj(reference_audio.file, buffer)
        
        # 2. Perform TTS Generation
        output_filename = f"out_{session_id}.wav"
        output_path = os.path.join(UPLOAD_DIR, output_filename)
        
        print(f"Synthesizing: '{text}' | Voice: {voice_id or 'Custom'} | Speed: {speed}")
        
        success = await tts_engine.generate(
            text=text,
            output_path=output_path,
            reference_audio_path=ref_path,
            voice_id=voice_id,
            speed=speed,
            intensity=intensity
        )

        if not success:
            raise HTTPException(status_code=500, detail="TTS Generation failed")

        return FileResponse(
            output_path, 
            media_type="audio/wav", 
            filename="output.wav"
        )

    except Exception as e:
        print(f"Error in backend: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health_check") # Renaming or removing to avoid confusion if needed, but I already added a new one
async def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
