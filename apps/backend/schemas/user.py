from pydantic import BaseModel

class AddUserRequest(BaseModel):
    username: str
    email: str
    password: str
