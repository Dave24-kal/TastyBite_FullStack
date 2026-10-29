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

router = APIRouter(prefix="/orders", tags=["Orders"])


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

    for item_data in order_data.items:
        food = db.scalar(
            select(Food).where(Food.id == item_data.food_id)
        )

        if food is None or not food.is_available:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Food item {item_data.food_id} is unavailable",
            )

        unit_price = Decimal(str(food.price))
        quantity = item_data.quantity

        total_amount += unit_price * quantity

        order_items.append(
            OrderItem(
                food_id=food.id,
                quantity=quantity,
                unit_price=unit_price,
            )
        )

    order = Order(
        user_id=current_user.id,
        customer_name=order_data.customer_name,
        customer_phone=order_data.customer_phone,
        delivery_address=order_data.delivery_address,
        total_amount=total_amount,
        status="pending",
        items=order_items,
    )

    try:
        db.add(order)
        db.commit()
        db.refresh(order)

        # Load the food relationships required by OrderResponse.
        db.refresh(order, attribute_names=["items"])

        order = db.scalar(
            select(Order)
            .options(
                selectinload(Order.items).selectinload(OrderItem.food)
            )
            .where(Order.id == order.id)
        )

        return order

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
    # Find the order and load its items and related food.
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

    # Define which status changes are allowed.
    # IMPORTANT: This dictionary must be outside the "if order is None" block.
    allowed_transitions = {
        "pending": {"confirmed", "cancelled"},
        "confirmed": {"preparing", "cancelled"},
        "preparing": {"ready", "cancelled"},
        "ready": {"delivered"},
        "delivered": set(),
        "cancelled": set(),
    }

    new_status = status_data.status

    # Prevent updating an order to its current status.
    if new_status == order.status:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Order is already {order.status}",
        )

    # Check whether the requested transition is allowed.
    allowed_next_statuses = allowed_transitions.get(order.status, set())

    if new_status not in allowed_next_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                f"Cannot change order status from "
                f"'{order.status}' to '{new_status}'"
            ),
        )

    # Save the new status to the database.
    order.status = new_status

    try:
        db.commit()
        db.refresh(order)

        # Reload relationships for the response.
        order = db.scalar(
            select(Order)
            .options(
                selectinload(Order.items).selectinload(OrderItem.food)
            )
            .where(Order.id == order_id)
        )

        return order

    except Exception:
        db.rollback()
        raise
