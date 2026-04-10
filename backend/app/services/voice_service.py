import os
import requests
from dotenv import load_dotenv

load_dotenv()

ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "dummy_key")
# Default Voice ID (e.g. Rachel/Bella or character-specific)
DEFAULT_VOICE_ID = "EXAVITQu4vr4xnSDxMaL" 

def generate_voice(text: str, voice_id: str = DEFAULT_VOICE_ID) -> bytes:
    """
    Generates text-to-speech audio using ElevenLabs API.
    Returns the audio content as bytes.
    """
    if ELEVENLABS_API_KEY == "dummy_key":
        # Return a simple mock byte string if no API key is provided
        return b"Mock Audio Content - Add ElevenLabs Key to hear real voices"
        
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    
    headers = {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": ELEVENLABS_API_KEY
    }
    
    data = {
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75
        }
    }
    
    response = requests.post(url, json=data, headers=headers)
    
    if response.status_code != 200:
        raise Exception(f"ElevenLabs API Error: {response.text}")
        
    return response.content
