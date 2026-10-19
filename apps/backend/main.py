from contextlib import asynccontextmanager
from fastapi import FastAPI
from apps.backend.api.v1 import api_router
from database import init_db


@asynccontextmanager
async def lifespan(_: FastAPI):
    try:
        await init_db()
    except Exception as exc:
        print(f"Error initializing the database: {exc}")
    yield


app = FastAPI(lifespan=lifespan)
app.include_router(api_router)


@app.get("/hello")
async def hello():
    return {
        "status": 200,
        "message": "Hello, World!",
    }