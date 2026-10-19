# fastapi_react_service
Template repo for FastApi + React + MySQL + Nginx docker service

## Run (Docker)
### UP
All services:
```
docker compose up --build
```

Only backend:
```
docker compose -f .\docker-compose.back.yml up --build
```

Only frontend:
```
docker compose -f .\docker-compose.front.yml up --build
```

### Down
```
docker compose down -v
```

## Dependency control (Poetry)
**VENV**:
```
python -m venv .venv
.venv\Scripts\activate
poetry env use python
```

**Poetry**:
```
pip install poetry
poetry install
poetry export --without-hashes -o requirements.txt                                                                                
```

To add dep:
```
poetry add <dep_name>
poetry install
```