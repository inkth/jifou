from sqlalchemy import Column, String, Float, DateTime, JSON, Integer, Date, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from ..core.database import Base
import uuid
from datetime import datetime

class UserModel(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.now)

    records = relationship("RecordModel", back_populates="owner")
    reports = relationship("DailyReportModel", back_populates="owner")

class RecordModel(Base):
    __tablename__ = "records"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    content = Column(String, nullable=False)
    record_type = Column(String, default="text")
    created_at = Column(DateTime, default=datetime.now)
    emotion_score = Column(Float)
    categories = Column(JSON) # 存储为 JSON 列表

    owner = relationship("UserModel", back_populates="records")

class DailyReportModel(Base):
    __tablename__ = "daily_reports"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    date = Column(Date, index=True)
    life_index = Column(Integer)
    health_score = Column(Integer)
    wealth_score = Column(Integer)
    happiness_score = Column(Integer)
    summary = Column(String)
    analysis = Column(String)
    risk_warning = Column(String)
    advice = Column(String)
    created_at = Column(DateTime, default=datetime.now)

    owner = relationship("UserModel", back_populates="reports")
