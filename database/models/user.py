from sqlalchemy import String
from sqlalchemy.orm import mapped_column, Mapped
from .base import Base, int_pk

class UserModel(Base):
    __tablename__ = "users"
    
    id: Mapped[int_pk]
    username: Mapped[str] = mapped_column(String, unique=True, index=True)
    password: Mapped[str] = mapped_column(String)