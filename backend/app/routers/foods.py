from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_admin
from app.models.food import Food
from app.models.user import User
from app.schemas.food_schema import FoodCreate, FoodResponse, FoodUpdate

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

@router.post(
    "/",
    response_model=FoodResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_food(
    food_data: FoodCreate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    new_food = Food(**food_data.model_dump())

    db.add(new_food)
    db.commit()
    db.refresh(new_food)

    return new_food

@router.patch("/{food_id}", response_model=FoodResponse)
def update_food(
    food_id: int,
    food_data: FoodUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    food = db.get(Food, food_id)

    if food is None:
        from fastapi import HTTPException

        raise HTTPException(
            status_code=404,
            detail="Food not found",
        )

    update_data = food_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(food, field, value)

    db.commit()
    db.refresh(food)

    return food