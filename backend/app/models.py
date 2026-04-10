from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    username = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Gamification
    xp = Column(Integer, default=0)
    level = Column(Integer, default=1)
    badges = Column(Text, default="") # Comma separated badges
    
    messages = relationship("Message", back_populates="user")
    relationships = relationship("Relationship", back_populates="user")
    
class Character(Base):
    __tablename__ = "characters"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    category = Column(String, index=True) # Romance, Anime, RPG, Mentor
    personality_traits = Column(Text)
    backstory = Column(Text)
    speaking_tone = Column(Text)
    avatar_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    messages = relationship("Message", back_populates="character")
    creator_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    relationships = relationship("Relationship", back_populates="character")

class Message(Base):
    __tablename__ = "messages"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    character_id = Column(Integer, ForeignKey("characters.id"))
    content = Column(Text)
    sender = Column(String) # 'user' or 'character'
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="messages")
    character = relationship("Character", back_populates="messages")

class Relationship(Base):
    __tablename__ = "relationships"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    character_id = Column(Integer, ForeignKey("characters.id"))
    affinity_score = Column(Integer, default=0)
    stage = Column(String, default="Stranger") # Stranger, Friend, Close, Romantic, Partner
    level = Column(Integer, default=1)
    last_interaction = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="relationships")
    character = relationship("Character", back_populates="relationships")
