# syntax=docker/dockerfile:1

# --- Backend: FastAPI (apps/backend/main.py) --------------------------------
FROM python:3.12-slim AS fastapi

WORKDIR /app

ENV PYTHONPATH=/app \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir --no-deps -r requirements.txt

COPY . .

ARG APP_PORT=8080
ENV APP_PORT=$APP_PORT
EXPOSE $APP_PORT

WORKDIR /app/apps/backend

CMD ["sh", "-c", "python -m uvicorn main:app --host 0.0.0.0 --port ${APP_PORT}"]

# --- Frontend: build React (Vite) -------------------------------------------
FROM node:20-alpine AS frontend_build

WORKDIR /app

COPY apps/frontend/package.json apps/frontend/package-lock.json ./
RUN npm ci

COPY apps/frontend/ ./
RUN npm run build

# --- Frontend: static files served by nginx ---------------------------------
FROM nginx:alpine AS frontend

COPY --from=frontend_build /app/dist /usr/share/nginx/html

EXPOSE 80

# --- Infrastructure images ---------------------------------------------------
FROM mariadb:latest AS database
FROM adminer:latest AS adminer
FROM nginx:alpine AS nginx
