from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.food import Food
from app.schemas.food_schema import FoodResponse


router = APIRouter(
    prefix="/foods",
    tags=["Foods"],
)


@router.get("/", response_model=list[FoodResponse])
def get_foods(db: Session = Depends(get_db)):
    statement = select(Food).where(
        Food.is_available.is_(True)
    )

    foods = db.scalars(statement).all()

    return foods