from fastapi import APIRouter

from .user import router as user_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(user_router)

__all__ = ["api_router"]