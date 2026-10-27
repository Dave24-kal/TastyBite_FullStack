from datetime import datetime

from sqlalchemy import BigInteger, DateTime, String,func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(
        BigInteger,
        primary_key=True,
        autoincrement=True
)

    full_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
)

    phone: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        unique= True
)

    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False
)
    role: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="customer",
        server_default="customer"
)    
       
    password_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False
)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
)

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now()
)