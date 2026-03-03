from sqlalchemy import Column, Integer, String, ForeignKey, Time, Boolean
from sqlalchemy.orm import relationship
from app.database import Base

class Timetable(Base):
    __tablename__ = "timetables"

    id = Column(Integer, primary_key=True, index=True)

    subject_id = Column(Integer, ForeignKey("subjects.id"), nullable=False)

    day_of_week = Column(String, nullable=False)  # Monday, Tuesday...
    start_time = Column(String, nullable=False)   # "10:00"
    end_time = Column(String, nullable=False)     # "11:00"
    classroom = Column(String, nullable=False)

    is_cancelled = Column(Boolean, default=False)

    subject = relationship("Subject")