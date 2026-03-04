from pydantic import BaseModel
from typing import Optional
from datetime import date, time

class Lecture(BaseModel):
    id: Optional[str] = None
    subject_id: str
    faculty_id: str
    date: date
    start_time: time
    end_time: time
    room: str
    conducted: bool = False