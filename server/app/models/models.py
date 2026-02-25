from sqlalchemy import Column, String, Float, DateTime, JSON, Integer, Date
from ..core.database import Base
import uuid
from datetime import datetime

class RecordModel(Base):
    __tablename__ = "records"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    content = Column(String, nullable=False)
    record_type = Column(String, default="text")
    created_at = Column(DateTime, default=datetime.now)
    emotion_score = Column(Float)
    categories = Column(JSON) # 存储为 JSON 列表

class DailyReportModel(Base):
    __tablename__ = "daily_reports"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    date = Column(Date, unique=True, index=True)
    life_index = Column(Integer)
    health_score = Column(Integer)
    wealth_score = Column(Integer)
    happiness_score = Column(Integer)
    summary = Column(String)
    analysis = Column(String)
    risk_warning = Column(String)
    advice = Column(String)
    created_at = Column(DateTime, default=datetime.now)
