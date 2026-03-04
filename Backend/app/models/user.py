from pydantic import BaseModel, EmailStr
from typing import Optional
from enum import Enum

class UserRole(str, Enum):
    admin = "admin"
    faculty = "faculty"
    student = "student"
    exam_dept = "exam_dept"

class User(BaseModel):
    id: Optional[str] = None
    email: EmailStr
    name: str
    hashed_password: str
    role: UserRole
    department: Optional[str] = None
    is_active: bool = True