import os
from pinecone import Pinecone, ServerlessSpec
from dotenv import load_dotenv
import openai

load_dotenv()

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "dummy-key")
INDEX_NAME = "personaverse-memory"

# Initialize Pinecone if API key is provided
if PINECONE_API_KEY:
    pc = Pinecone(api_key=PINECONE_API_KEY)
    
    # Check if index exists, else create it
    if INDEX_NAME not in [idx.name for idx in pc.list_indexes()]:
        pc.create_index(
            name=INDEX_NAME, 
            dimension=1536, # OpenAI embedding dimension
            metric='cosine',
            spec=ServerlessSpec(
                cloud='aws',
                region='us-east-1'
            )
        )
    index = pc.Index(INDEX_NAME)
else:
    index = None

def store_memory(user_id: int, character_id: int, text: str):
    """
    Embeds the user text and stores it in Pinecone for long term retrieval.
    """
    if index is None or OPENAI_API_KEY == "dummy-key":
        print("Mock: Stored memory -", text)
        return
        
    # Create embedding
    from openai import OpenAI
    client = OpenAI(api_key=OPENAI_API_KEY)
    try:
        res = client.embeddings.create(input=[text], model="text-embedding-ada-002")
        embedding = res.data[0].embedding
        
        # Upsert to Pinecone
        vector_id = f"{user_id}_{character_id}_{hash(text)}"
        index.upsert(vectors=[(vector_id, embedding, {"user_id": user_id, "character_id": character_id, "text": text})])
    except Exception as e:
        print(f"Error storing memory: {e}")

def retrieve_relevant_memory(user_id: int, character_id: int, query: str) -> list:
    """
    Retrieves the most semantically similar past conversation snippets to use as context.
    """
    if index is None or OPENAI_API_KEY == "dummy-key":
        return []
        
    from openai import OpenAI
    client = OpenAI(api_key=OPENAI_API_KEY)
    
    try:
        res = client.embeddings.create(input=[query], model="text-embedding-ada-002")
        embedding = res.data[0].embedding
        
        result = index.query(
            vector=embedding,
            filter={
                "user_id": {"$eq": user_id},
                "character_id": {"$eq": character_id}
            },
            top_k=3,
            include_metadata=True
        )
        
        matches = [match['metadata']['text'] for match in result['matches']]
        return matches
    except Exception as e:
        print(f"Error retrieving memory: {e}")
        return []
