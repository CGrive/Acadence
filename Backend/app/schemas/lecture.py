from pydantic import BaseModel
from datetime import date, time

class LectureBase(BaseModel):
    subject_id: str
    date: date
    start_time: time
    end_time: time
    room: str

class LectureCreate(LectureBase):
    faculty_id: str

class LectureOut(LectureBase):
    id: str
    faculty_id: str
    conducted: bool