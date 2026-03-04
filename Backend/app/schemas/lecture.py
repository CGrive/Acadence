from pydantic import BaseModel
from typing import Optional

class LectureBase(BaseModel):
    subject_id: str
    faculty_id: str
    date: str          # ISO date string, e.g., "2026-03-06"
    start_time: str    # ISO time string, e.g., "09:00:00"
    end_time: str
    room: str

class LectureCreate(LectureBase):
    conducted: bool = False

class LectureOut(LectureBase):
    id: str
    conducted: bool
    subject_name: Optional[str] = None