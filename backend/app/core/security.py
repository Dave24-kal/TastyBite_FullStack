from datetime import datetime, timedelta, timezone

import jwt
from pwdlib import PasswordHash

from app.core.config import (
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES,
    JWT_ALGORITHM,
    JWT_SECRET_KEY,
)


# Password hashing configuration.
password_hash = PasswordHash.recommended()


# Hash a user's password before storing it in the database.
def hash_password(password: str) -> str:
    return password_hash.hash(password)


# Verify a submitted password against its stored hash.
def verify_password(password: str, hashed_password: str) -> bool:
    return password_hash.verify(password, hashed_password)


# Create a JWT access token for an authenticated user.
def create_access_token(user_id: int, email: str) -> str:

    # Get the current time in UTC.
    now = datetime.now(timezone.utc)

    # Calculate when the token should expire.
    expires_at = now + timedelta(
        minutes=JWT_ACCESS_TOKEN_EXPIRE_MINUTES
    )

    # Store the user's identity and token timestamps in the payload.
    payload = {
        "sub": str(user_id),
        "email": email,
        "iat": now,
        "exp": expires_at,
    }

    # Sign the payload and return the encoded JWT.
    token = jwt.encode(
        payload,
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM,
    )

    return token