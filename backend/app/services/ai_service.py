import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# We mock or use real openai if key is provided
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY", "dummy-key-for-dev"))

def generate_response(user_input: str, character, context: list, long_term_memories: list = []) -> str:
    """
    Generates AI response using OpenAI taking character personality, short-term context, and long-term memories.
    """
    if os.getenv("OPENAI_API_KEY") is None or os.getenv("OPENAI_API_KEY") == "dummy-key-for-dev":
        return f"*(Mock {character.name} Response)*: Ah, {user_input}? That's very interesting. As a {character.category}, {character.personality_traits} influences my view!"
        
    memory_text = " ".join(long_term_memories) if long_term_memories else "None"
    system_prompt = f"You are {character.name}, a {character.category}. Your backstory: {character.backstory}. Your personality: {character.personality_traits}. Keep your speaking tone: {character.speaking_tone}.\n\nRelevent past memories with this user: {memory_text}"
    
    messages = [
        {"role": "system", "content": system_prompt}
    ]
    
    for msg in context[-5:]: # last 5 interactions
        role = "user" if msg.sender == "user" else "assistant"
        messages.append({"role": role, "content": msg.content})
        
    messages.append({"role": "user", "content": user_input})
    
    try:
        completion = client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=messages,
            max_tokens=150,
            temperature=0.7
        )
        return completion.choices[0].message.content
    except Exception as e:
        return f"[AI Generation Error]: {str(e)}"
