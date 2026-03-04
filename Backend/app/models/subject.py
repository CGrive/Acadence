from pydantic import BaseModel
from typing import Optional

class Subject(BaseModel):
    id: Optional[str] = None
    name: str
    code: str
    department: str
    faculty_id: Optional[str] = None
    semester: int