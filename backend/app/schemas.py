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
    # New fields for frontend sync
    affinity_score: Optional[int] = 0
    relationship_stage: Optional[str] = "Stranger"
    xp_gained: Optional[int] = 0
    class Config:
        orm_mode = True

class RelationshipBase(BaseModel):
    user_id: int
    character_id: int
    affinity_score: int
    stage: str
    level: int

class Relationship(RelationshipBase):
    id: int
    last_interaction: datetime
    class Config:
        orm_mode = True

class UserProfile(BaseModel):
    id: int
    username: str
    xp: int
    level: int
    badges: str
    class Config:
        orm_mode = True
