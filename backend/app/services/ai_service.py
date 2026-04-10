import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "dummy-key")

def check_moderation(text: str) -> bool:
    """
    Checks if the content violates OpenAI safety policies.
    Returns True if safe, False if flagged.
    """
    if OPENAI_API_KEY == "dummy-key":
        return True
    
    client = OpenAI(api_key=OPENAI_API_KEY)
    response = client.moderations.create(input=text)
    return not response.results[0].flagged

def generate_response(character_data: dict, user_message: str, chat_history: list = None, memories: list = None) -> str:
    """
    Generates AI response using OpenAI taking character personality, short-term context, and long-term memories.
    """
    if os.getenv("OPENAI_API_KEY") is None or os.getenv("OPENAI_API_KEY") == "dummy-key-for-dev":
        return f"*(Mock {character_data.get('name', 'Character')} Response)*: Ah, {user_message}? That's very interesting. As a {character_data.get('category')}, {character_data.get('personality_traits')} influences my view!"
        
    # Construct system prompt with character personality and memory
    system_prompt = f"""
    You are {character_data['name']}. 
    Personality: {character_data['personality_traits']}
    Backstory: {character_data['backstory']}
    Speaking Tone: {character_data['speaking_tone']}
    
    CORE RULES:
    1. Stay in character AT ALL TIMES.
    2. Respond naturally, as if in a real conversation.
    3. Use the contextual memories provided below to inform your responses.
    4. Do not mention you are an AI.
    5. Maintain the current relationship affinity stage.
    """
    
    if memories:
        system_prompt += "\nRelevant Context from Past Conversations:\n" + "\n".join(memories)
    
    # Check moderation first
    if not check_moderation(user_message):
        return "I'm sorry, I can't talk about that. Let's keep things respectful."
        
    messages = [{"role": "system", "content": system_prompt}]
    if chat_history:
        messages.extend(chat_history)
    messages.append({"role": "user", "content": user_message})
    
    try:
        client = OpenAI(api_key=OPENAI_API_KEY)
        response = client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=messages,
            temperature=0.7,
            max_tokens=300
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"Error generating AI response: {e}")
        return "*(Thinking...)* I'm a bit overwhelmed right now, let's try again in a moment."
