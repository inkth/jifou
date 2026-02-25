from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Optional
from enum import Enum

class RecordType(str, Enum):
    TEXT = "text"
    VOICE = "voice"

class RecordBase(BaseModel):
    content: str = Field(..., description="记录内容")
    record_type: RecordType = Field(default=RecordType.TEXT, description="记录类型")

class RecordCreate(RecordBase):
    pass

class Record(RecordBase):
    id: str
    created_at: datetime
    emotion_score: float = Field(..., ge=0, le=1, description="情绪评分 0-1")
    categories: List[str] = Field(default_factory=list, description="分类标签，如 health, wealth")

    class Config:
        from_attributes = True
