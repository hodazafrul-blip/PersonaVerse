from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CharacterBase(BaseModel):
    name: str
    category: str
    personality_traits: str
    backstory: str
    speaking_tone: str
    avatar_url: Optional[str] = None

class CharacterCreate(CharacterBase):
    pass

class Character(CharacterBase):
    id: int
    created_at: datetime
    class Config:
        orm_mode = True

class MessageCreate(BaseModel):
    user_id: int
    character_id: int
    content: str

class MessageResponse(BaseModel):
    id: int
    content: str
    sender: str
    timestamp: datetime
    class Config:
        orm_mode = True
