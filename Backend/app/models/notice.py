from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum

class NoticeTarget(str, Enum):
    faculty = "faculty"
    students = "students"
    all = "all"

class Notice(BaseModel):
    id: Optional[str] = None
    title: str
    content: str
    target: NoticeTarget
    sender_id: str
    timestamp: datetime = datetime.utcnow()