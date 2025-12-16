#!/usr/bin/env python3
"""
Script to add a user to MongoDB database
Usage: python add_user.py
"""
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext

# MongoDB connection details (update these if different)
MONGO_HOST = "localhost"  # Use "mongodb-service" if running inside cluster
MONGO_PORT = 27017
MONGO_USER = "admin"  # base64 decode of YWRtaW4=
MONGO_PASSWORD = "admin123"  # base64 decode of YWRtaW4xMjM=
MONGO_DB = "appdb"

# User details to add
USER_EMAIL = "mahmedraza90@gmail.com"
USER_PASSWORD = "123"

password_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_hashed_password(password: str) -> str:
    return password_context.hash(password)


async def add_user():
    """Add user to MongoDB"""
    # Connect to MongoDB
    client = AsyncIOMotorClient(
        MONGO_HOST,
        MONGO_PORT,
        username=MONGO_USER,
        password=MONGO_PASSWORD,
    )
    
    db = client[MONGO_DB]
    users_collection = db["User"]  # Beanie uses class name as collection name
    
    # Check if user already exists
    existing_user = await users_collection.find_one({"email": USER_EMAIL})
    if existing_user:
        print(f"❌ User with email {USER_EMAIL} already exists!")
        print(f"Existing user: {existing_user}")
        return
    
    # Create new user document
    import uuid
    user_doc = {
        "uuid": str(uuid.uuid4()),
        "email": USER_EMAIL,
        "first_name": "Mahmed",
        "last_name": "Raza",
        "hashed_password": get_hashed_password(USER_PASSWORD),
        "provider": None,
        "picture": None,
        "is_active": True,
        "is_superuser": False,
    }
    
    # Insert user
    result = await users_collection.insert_one(user_doc)
    print(f"✅ User added successfully!")
    print(f"User ID: {result.inserted_id}")
    print(f"Email: {USER_EMAIL}")
    print(f"Password: {USER_PASSWORD}")
    
    # Verify insertion
    inserted_user = await users_collection.find_one({"email": USER_EMAIL})
    print(f"\n📋 User document in database:")
    print(f"  Email: {inserted_user['email']}")
    print(f"  UUID: {inserted_user['uuid']}")
    print(f"  First Name: {inserted_user.get('first_name', 'N/A')}")
    print(f"  Last Name: {inserted_user.get('last_name', 'N/A')}")
    print(f"  Is Active: {inserted_user['is_active']}")
    print(f"  Is Superuser: {inserted_user['is_superuser']}")
    
    client.close()


if __name__ == "__main__":
    print("🔄 Adding user to MongoDB...")
    asyncio.run(add_user())
