from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Subject(Base):
    __tablename__ = "subjects"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    semester = Column(Integer, nullable=False)
    department = Column(String, nullable=False)

    assigned_professor_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    assigned_professor = relationship("User")