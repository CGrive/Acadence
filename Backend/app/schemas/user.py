from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from ..models.user import UserRole

class UserBase(BaseModel):
    email: EmailStr
    name: str
    role: UserRole
    department: Optional[str] = None

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=72)

    @validator('password')
    def password_not_too_long(cls, v):
        if len(v) > 72:
            raise ValueError('Password must not exceed 72 characters')
        return v

class UserOut(UserBase):
    id: str
    is_active: bool 