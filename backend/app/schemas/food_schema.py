from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class FoodCreate(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    description: str = Field(min_length=5)
    price: Decimal = Field(gt=0, max_digits=10, decimal_places=2)
    category: str = Field(min_length=2, max_length=100)
    image_url: str | None = None
    is_available: bool = True

class FoodUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=150)
    description: str | None = Field(default=None, min_length=5)
    price: Decimal | None = Field(
        default=None,
        gt=0,
        max_digits=10,
        decimal_places=2,
    )
    category: str | None = Field(default=None, min_length=2, max_length=100)
    image_url: str | None = None
    is_available: bool | None = None

class FoodResponse(BaseModel):
    id: int
    name: str
    description: str
    price: Decimal
    category: str
    image_url: str | None
    is_available: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)