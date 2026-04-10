import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "dummy_key")

def generate_avatar(prompt: str) -> str:
    """
    Generates a character avatar image using OpenAI DALL-E 3.
    Returns the URL to the generated image.
    """
    if OPENAI_API_KEY == "dummy_key":
        print(f"Mock Image Generation for prompt: '{prompt}'")
        return "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"
    
    client = OpenAI(api_key=OPENAI_API_KEY)
    
    try:
        response = client.images.generate(
            model="dall-e-3",
            prompt=f"A realistic portrait of an AI companion character: {prompt}",
            size="1024x1024",
            quality="standard",
            n=1,
        )
        
        image_url = response.data[0].url
        return image_url
    except Exception as e:
        print(f"Error generating avatar: {e}")
        # Fallback to sample image on error
        return "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg"
