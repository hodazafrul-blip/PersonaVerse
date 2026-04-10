from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from . import models, schemas, database
from .services import ai_service, memory_service
import os

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
    return {"message": "Welcome to PersonaVerse API. Unlimited AI wait for you."}

@app.post("/characters/", response_model=schemas.Character)
def create_character(character: schemas.CharacterCreate, db: Session = Depends(database.get_db)):
    db_character = models.Character(**character.dict())
    db.add(db_character)
    db.commit()
    db.refresh(db_character)
    return db_character

@app.get("/characters/", response_model=list[schemas.Character])
def read_characters(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    characters = db.query(models.Character).offset(skip).limit(limit).all()
    return characters

@app.post("/chat/", response_model=schemas.MessageResponse)
def chat_with_character(message: schemas.MessageCreate, db: Session = Depends(database.get_db)):
    # 1. Verify character
    character = db.query(models.Character).filter(models.Character.id == message.character_id).first()
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
        
    # 2. Save user message
    user_msg = models.Message(user_id=message.user_id, character_id=message.character_id, content=message.content, sender="user")
    db.add(user_msg)
    db.commit()
    
    # 3. Retrieve context & long term memories
    context = db.query(models.Message).filter(models.Message.character_id == message.character_id).order_by(models.Message.timestamp.desc()).limit(10).all()
    context.reverse() # chronological
    long_term_memories = memory_service.retrieve_relevant_memory(message.user_id, message.character_id, message.content)
    
    ai_response_text = ai_service.generate_response(user_input=message.content, character=character, context=context, long_term_memories=long_term_memories)
    
    # 4. Save AI message
    ai_msg = models.Message(user_id=message.user_id, character_id=message.character_id, content=ai_response_text, sender="character")
    db.add(ai_msg)
    db.commit()
    db.refresh(ai_msg)
    
    # 5. Store memory to vector DB
    memory_service.store_memory(message.user_id, message.character_id, f"User: {message.content}\nAI: {ai_response_text}")
    
    return ai_msg
