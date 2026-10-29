from decimal import Decimal
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.core.database import get_db
from app.core.dependencies import get_current_admin, get_current_user
from app.models.food import Food
from app.models.order import Order, OrderItem
from app.models.user import User
from app.schemas.order_schema import (
    OrderCreate,
    OrderResponse,
    OrderStatusUpdate,
)

router = APIRouter(
    prefix="/orders",
    tags=["Orders"],
)


@router.post(
    "/",
    response_model=OrderResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_order(
    order_data: OrderCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    total_amount = Decimal("0.00")
    order_items = []

    # Check every requested food before saving the order.
    for item in order_data.items:
        food = db.scalar(
            select(Food).where(Food.id == item.food_id)
        )

        if food is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Food with ID {item.food_id} was not found",
            )

        if not food.is_available:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{food.name} is currently unavailable",
            )

        # Always use the price stored in PostgreSQL.
        unit_price = food.price
        subtotal = unit_price * item.quantity

        total_amount += subtotal

        order_items.append(
            OrderItem(
                food_id=food.id,
                quantity=item.quantity,
                unit_price=unit_price,
            )
        )

    # Create the main order record.
    new_order = Order(
        user_id=current_user.id,
        customer_name=order_data.customer_name,
        customer_phone=order_data.customer_phone,
        delivery_address=order_data.delivery_address,
        total_amount=total_amount,
        status="pending",
        items=order_items,
    )

    try:
        db.add(new_order)
        db.commit()

        # Retrieve the saved order ID and other database values.
        db.refresh(new_order)

        # Load the order items so they can be returned in the response.
        saved_order = db.scalar(
    select(Order)
    .options(
        selectinload(Order.items).selectinload(OrderItem.food)
    )
    .where(Order.id == new_order.id)
)
        if saved_order is None:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Order was saved but could not be retrieved",
            )

        return saved_order

    except Exception:
        db.rollback()
        raise


@router.get(
    "/my-orders",
    response_model=list[OrderResponse],
)
def get_my_orders(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    orders = db.scalars(
    select(Order)
    .options(
        selectinload(Order.items).selectinload(OrderItem.food)
    )
    .where(Order.user_id == current_user.id)
    .order_by(Order.created_at.desc())
).all()

    return orders

@router.get(
    "/",
    response_model=list[OrderResponse],
)
def get_all_orders(
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    orders = db.scalars(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.food)
        )
        .order_by(Order.created_at.desc())
    ).all()

    return orders


@router.patch(
    "/{order_id}/status",
    response_model=OrderResponse,
)
def update_order_status(
    order_id: int,
    status_data: OrderStatusUpdate,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    order = db.scalar(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.food)
        )
        .where(Order.id == order_id)
    )

    if order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found",
        )

    order.status = status_data.status

    db.commit()
    db.refresh(order)

    return order