from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class OrderItemCreate(BaseModel):
    food_id: int = Field(gt=0)
    quantity: int = Field(gt=0, le=100)


class OrderCreate(BaseModel):
    customer_name: str = Field(min_length=3, max_length=100)
    customer_phone: str = Field(min_length=9, max_length=13)
    delivery_address: str = Field(min_length=5, max_length=500)
    items: list[OrderItemCreate] = Field(min_length=1)

    @field_validator("customer_name", "delivery_address")
    @classmethod
    def validate_required_text(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("This field cannot be empty")
        return value

    @field_validator("customer_phone")
    @classmethod
    def validate_phone(cls, value: str) -> str:
        import re

        pattern = r"(\+251|0)?9\d{8}"
        if not re.fullmatch(pattern, value):
            raise ValueError("Invalid Ethiopian phone number")
        return value


class OrderItemResponse(BaseModel):
    id: int
    food_id: int
    food_name: str
    food_image_url: str | None
    quantity: int
    unit_price: Decimal

    model_config = ConfigDict(from_attributes=True)

class OrderResponse(BaseModel):
    id: int
    user_id: int
    customer_name: str
    customer_phone: str
    delivery_address: str
    total_amount: Decimal
    status: str
    created_at: datetime
    items: list[OrderItemResponse]

    model_config = ConfigDict(from_attributes=True)