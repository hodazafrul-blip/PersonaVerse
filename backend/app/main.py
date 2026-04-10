from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from . import models, schemas, database
from .services import ai_service, memory_service, image_service
from .utils import calculate_stage
from datetime import datetime

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="PersonaVerse AI Companion Platform")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to PersonaVerse API. All features unlocked."}

@app.post("/characters/", response_model=schemas.Character)
def create_character(character: schemas.CharacterCreate, db: Session = Depends(database.get_db)):
    # Trigger DALL-E generation for avatar
    if not character.avatar_url:
        character.avatar_url = image_service.generate_avatar(f"{character.name}: {character.personality_traits}")
        
    db_character = models.Character(**character.dict())
    db.add(db_character)
    db.commit()
    db.refresh(db_character)
    return db_character

@app.get("/characters/", response_model=list[schemas.Character])
def read_characters(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    return db.query(models.Character).offset(skip).limit(limit).all()

@app.get("/profile/{user_id}", response_model=schemas.UserProfile)
def get_profile(user_id: int, db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        # Auto-create guest for convenience in prototype
        user = models.User(id=user_id, username=f"User_{user_id}", email=f"user{user_id}@example.com")
        db.add(user)
        db.commit()
        db.refresh(user)
    return user

@app.post("/chat/", response_model=schemas.MessageResponse)
def chat_with_character(message: schemas.MessageCreate, db: Session = Depends(database.get_db)):
    character = db.query(models.Character).filter(models.Character.id == message.character_id).first()
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    # Get or create relationship
    rel = db.query(models.Relationship).filter(
        models.Relationship.user_id == message.user_id, 
        models.Relationship.character_id == message.character_id
    ).first()
    if not rel:
        rel = models.Relationship(user_id=message.user_id, character_id=message.character_id)
        db.add(rel)
    
    # User XP and Affinity gain
    user = db.query(models.User).filter(models.User.id == message.user_id).first()
    if user:
        user.xp += 10
        if user.xp >= user.level * 100:
            user.level += 1
            
    rel.affinity_score += 5
    rel.stage = calculate_stage(rel.affinity_score)
    rel.last_interaction = datetime.utcnow()
    
    db.commit()

    # Chat context & response
    history = db.query(models.Message).filter(
        models.Message.user_id == message.user_id,
        models.Message.character_id == message.character_id
    ).order_by(models.Message.timestamp.desc()).limit(10).all()
    history = [{"role": "user" if m.sender == "user" else "assistant", "content": m.content} for m in reversed(history)]
    
    memories = memory_service.retrieve_relevant_memory(message.user_id, message.character_id, message.content)
    
    char_data = {
        "name": character.name,
        "personality_traits": character.personality_traits,
        "backstory": character.backstory,
        "speaking_tone": character.speaking_tone
    }
    
    ai_response = ai_service.generate_response(char_data, message.content, history, memories)
    
    # Save messages
    db.add(models.Message(user_id=message.user_id, character_id=message.character_id, content=message.content, sender="user"))
    ai_msg = models.Message(user_id=message.user_id, character_id=message.character_id, content=ai_response, sender="character")
    db.add(ai_msg)
    db.commit()
    db.refresh(ai_msg)

    # Store memory
    memory_service.store_memory(message.user_id, message.character_id, f"User: {message.content}\nAI: {ai_response}")

    # Map to response schema
    return {
        "id": ai_msg.id,
        "content": ai_msg.content,
        "sender": ai_msg.sender,
        "timestamp": ai_msg.timestamp,
        "affinity_score": rel.affinity_score,
        "relationship_stage": rel.stage,
        "xp_gained": 10
    }
