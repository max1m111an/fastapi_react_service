FROM python:3.12-slim AS backend_main

WORKDIR /app

ENV PYTHONPATH=/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

WORKDIR /app/apps/backend

ARG APP_PORT=8080

ENV APP_PORT=$APP_PORT

EXPOSE $APP_PORT

CMD ["sh", "-c", "python -m uvicorn main:app --host 0.0.0.0 --port $APP_PORT"]

#FROM node:20-slim AS frontend_main
#
#WORKDIR /app
#
#COPY . .
#
#RUN npm install
#
#CMD ["npm", "start"]

FROM mariadb:latest AS database
FROM adminer:latest AS adminer
FROM nginx:latest AS nginx