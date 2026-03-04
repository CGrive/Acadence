from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class Enrollment(BaseModel):
    id: Optional[str] = None
    student_id: str
    subject_id: str
    enrollment_date: datetime = datetime.utcnow()