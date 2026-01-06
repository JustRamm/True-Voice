# Activate venv
.\venv\Scripts\Activate.ps1

# Set License Agreement
$env:TTS_AGREEMENT = "1"

# Start FastAPI
python main.py
