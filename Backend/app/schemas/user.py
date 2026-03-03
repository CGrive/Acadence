from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str
    department: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    department: str

    class Config:
        orm_mode = True