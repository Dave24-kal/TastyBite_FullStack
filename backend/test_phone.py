from pydantic import ValidationError

from app.schemas.user import UserCreate


test_data = {
    "full_name": "Dawit Kalbesa",
    "email": "dawit@example.com",
    "password": "Password123!"
}

phone_numbers = [
    "0912345678",
    "912345678",
    "+251912345678",
    "51912345678",
    "1234567890",
    "091234"
]

for phone in phone_numbers:
    try:
        UserCreate(**{**test_data, "phone": phone})
        print(f"{phone}: VALID")
    except ValidationError:
        print(f"{phone}: INVALID")