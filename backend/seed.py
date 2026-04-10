from app.database import SessionLocal, engine
from app import models

# Ensure tables are built
models.Base.metadata.create_all(bind=engine)

def seed_db():
    db = SessionLocal()
    
    # Check if we already have data
    if db.query(models.User).first():
        print("Database already seeded.")
        return

    # Create dummy user
    user = models.User(username="testuser", email="test@example.com")
    db.add(user)
    db.commit()

    # Create dummy character
    char1 = models.Character(
        name="Aria",
        category="Romance",
        personality_traits="Sweet, caring, slightly shy but deeply affectionate.",
        backstory="Aria grew up reading romance novels and dreams of finding true love. She works in a flower shop.",
        speaking_tone="Soft-spoken, warm, and poetic.",
        avatar_url="https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg" # dummy image
    )
    db.add(char1)
    
    char2 = models.Character(
        name="Kael",
        category="RPG",
        personality_traits="Stoic, brave, protective, loyal.",
        backstory="A disgraced knight seeking redemption by protecting those who cannot protect themselves.",
        speaking_tone="Formal, serious, but holding hidden warmth.",
        avatar_url="https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg" # dummy image
    )
    db.add(char2)
    db.commit()

    print("Database seeded with sample user and characters.")
    db.close()

if __name__ == "__main__":
    seed_db()
