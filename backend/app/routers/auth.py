from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session
from app.core.database import get_db



router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

@router.get("/db_test")
def db_test(db: Session = Depends(get_db)):
    result = db.execute(text("Select 1"))
    return {"database": result.scalar()}