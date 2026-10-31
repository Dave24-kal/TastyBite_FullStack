import re
from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict


class UserCreate(BaseModel):
    full_name: str = Field(min_length=3, max_length=100)
    phone: str = Field(min_length=9, max_length=13)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, value: str) -> str:
        pattern = r"(\+125|0)?9\d{8}"

        if not re.fullmatch(pattern, value):
            raise ValueError("Invalid phone number format")
            
        return value

    @field_validator("password")
    @classmethod
    def validate_password(cls, value: str) -> str:
        if not any(char.isupper() for char in value):
            raise ValueError("Password must contain an uppercase letter")

        if not any(char.islower() for char in value):
            raise ValueError("Password must contain a lowercase letter")

        if not any(char.isdigit() for char in value):
            raise ValueError("Password must contain a number")

        if not any(not char.isalnum() for char in value):
            raise ValueError("Password must contain a special character")

        return value


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    full_name: str
    phone: str
    email: EmailStr
    role: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse