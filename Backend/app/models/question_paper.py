from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum

class PaperStatus(str, Enum):
    draft = "draft"
    pending = "pending"
    approved = "approved"
    rejected = "rejected"

class QuestionPaper(BaseModel):
    id: Optional[str] = None
    subject_id: str
    faculty_id: str
    exam_type: str
    file_url: str
    status: PaperStatus = PaperStatus.draft
    submission_date: datetime = datetime.utcnow()
    reviewed_by: Optional[str] = None
    review_date: Optional[datetime] = None