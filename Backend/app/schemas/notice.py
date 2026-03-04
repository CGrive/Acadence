from pydantic import BaseModel
from datetime import datetime
from ..models.notice import NoticeTarget

class NoticeBase(BaseModel):
    title: str
    content: str
    target: NoticeTarget

class NoticeCreate(NoticeBase):
    pass

class NoticeOut(NoticeBase):
    id: str
    sender_id: str
    timestamp: datetime