from sqlalchemy import String
from sqlalchemy.orm import mapped_column, Mapped
from .base import Base, int_pk

class UserModel(Base):
    __tablename__ = "users"
    
    id: Mapped[int_pk]
    username: Mapped[str] = mapped_column(String(150), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password: Mapped[str] = mapped_column(String(255))