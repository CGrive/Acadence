from pydantic import BaseModel
from datetime import date, time
from ..models.invigilation import InvigilationStatus

class InvigilationBase(BaseModel):
    exam_name: str
    subject: str
    room: str
    date: date
    start_time: time
    end_time: time

class InvigilationCreate(InvigilationBase):
    faculty_id: Optional[str] = None

class InvigilationOut(InvigilationBase):
    id: str
    faculty_id: Optional[str] = None
    status: InvigilationStatus