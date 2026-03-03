from pydantic import BaseModel
from typing import Optional

class TimetableCreate(BaseModel):
    subject_id: int
    day_of_week: str
    start_time: str
    end_time: str
    classroom: str

class TimetableResponse(BaseModel):
    id: int
    subject_id: int
    day_of_week: str
    start_time: str
    end_time: str
    classroom: str
    is_cancelled: bool

    class Config:
        orm_mode = True