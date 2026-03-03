from pydantic import BaseModel
from typing import Optional

class SubjectCreate(BaseModel):
    name: str
    semester: int
    department: str

class SubjectAssignProfessor(BaseModel):
    professor_id: int

class SubjectResponse(BaseModel):
    id: int
    name: str
    semester: int
    department: str
    assigned_professor_id: Optional[int]

    class Config:
        orm_mode = True