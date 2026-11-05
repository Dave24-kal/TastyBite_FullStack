from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_admin
from app.models.user import User
from app.models.food import Food
from app.models.order import Order

router = APIRouter(
    prefix="/admin/dashboard",
    tags=["Admin Dashboard"],
)


@router.get("/stats")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    # Count all orders
    total_orders = db.scalar(
        select(func.count()).select_from(Order)
    )

    # Count registered customers (exclude administrators)
    total_customers = db.scalar(
        select(func.count())
        .select_from(User)
        .where(User.role == "customer")
    )

    # Count available foods
    available_foods = db.scalar(
        select(func.count())
        .select_from(Food)
        .where(Food.is_available == True)
    )

    # Count pending orders
    pending_orders = db.scalar(
        select(func.count())
        .select_from(Order)
        .where(Order.status == "pending")
    )

    return {
        "total_orders": total_orders,
        "total_customers": total_customers,
        "available_foods": available_foods,
        "pending_orders": pending_orders,
    }