from pydantic import BaseModel
from typing import Optional
from datetime import date, time
from enum import Enum

class InvigilationStatus(str, Enum):
    unassigned = "unassigned"
    assigned = "assigned"

class Invigilation(BaseModel):
    id: Optional[str] = None
    exam_name: str
    subject: str
    room: str
    date: date
    start_time: time
    end_time: time
    faculty_id: Optional[str] = None
    status: InvigilationStatus = InvigilationStatus.unassigned