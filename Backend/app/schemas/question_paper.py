from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.question_paper import PaperStatus

class QuestionPaperBase(BaseModel):
    subject_id: str
    exam_type: str
    file_url: str

class QuestionPaperCreate(QuestionPaperBase):
    pass

class QuestionPaperOut(QuestionPaperBase):
    id: str
    faculty_id: str
    status: PaperStatus
    submission_date: datetime
    reviewed_by: Optional[str] = None
    review_date: Optional[datetime] = None
    subject_name: str = ""  