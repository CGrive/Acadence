from pydantic import BaseModel
from typing import Optional

class SubjectBase(BaseModel):
    name: str
    code: str
    department: str
    semester: int

class SubjectCreate(SubjectBase):
    faculty_id: Optional[str] = None

class SubjectOut(SubjectBase):
    id: str
    faculty_id: Optional[str] = None