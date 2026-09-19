from sqlalchemy import BigInteger, DateTime, String
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
    nullable=False
)

    email: Mapped[str] = mapped_column(
    String(255),
    unique=True,
    nullable=False
)

    password_hash: Mapped[str] = mapped_column(
    String(255),
    nullable=False
)


    created_at: Mapped[DateTime] = mapped_column(
    DateTime(timezone=True),
    nullable=False
)
    updated_at: Mapped[DateTime] = mapped_column(
    DateTime(timezone=True),
    nullable=False
)