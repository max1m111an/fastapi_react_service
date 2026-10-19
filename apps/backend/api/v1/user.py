from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...schemas.user import (
    AddUserRequest,
)
from database import get_db
from database.models import UserModel

router = APIRouter(tags=["calculator"])

@router.post("/users")
async def add_user(
    user_request: AddUserRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    # Check if the username or email already exists
    existing_user = await db.execute(
        select(UserModel).where(
            (UserModel.username == user_request.username) |
            (UserModel.email == user_request.email)
        )
    )
    existing_user = existing_user.scalar_one_or_none()

    if existing_user:
        raise HTTPException(status_code=400, detail="Username or email already exists")

    # Create a new user
    new_user = UserModel(
        username=user_request.username,
        email=user_request.email,
        password=user_request.password  # In a real application, make sure to hash the password!
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    return {
        "status": 200,
        "message": "User added successfully",
        "user_id": new_user.id,
        }