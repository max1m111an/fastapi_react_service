from os import getenv

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy import URL
from dotenv import load_dotenv
from .models import Base

load_dotenv()


DB_HOST = getenv("DB_HOST", "localhost")
DB_PORT = getenv("DB_PORT", "3306")
DB_NAME = getenv("DB_NAME", "mydb")
DB_USER = getenv("DB_USER", "admin")
DB_PASS = getenv("DB_PASS", "")
DB_SCHEME = getenv("DB_SCHEME", "mysql+aiomysql")

DATABASE_URL = URL.create(
    DB_SCHEME,
    username=DB_USER,
    password=DB_PASS,  # plain (unescaped) text
    host=DB_HOST,
    port=DB_PORT,
    database=DB_NAME,
)


engine = create_async_engine(DATABASE_URL, echo=True)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)