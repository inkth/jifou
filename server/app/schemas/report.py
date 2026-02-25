from pydantic import BaseModel, Field
from datetime import date
from typing import List, Optional

class DailyReport(BaseModel):
    date: date
    life_index: int = Field(..., ge=0, le=100, description="今日人生指数")
    health_score: int = Field(..., ge=0, le=100)
    wealth_score: int = Field(..., ge=0, le=100)
    happiness_score: int = Field(..., ge=0, le=100)
    summary: str = Field(..., description="今日总结")
    analysis: str = Field(..., description="维度解析")
    risk_warning: str = Field(..., description="风险提示")
    advice: str = Field(..., description="明日建议")

    class Config:
        from_attributes = True

class WeeklyReport(BaseModel):
    start_date: date
    end_date: date
    summary: str
    trends: List[int]
    is_locked: bool = True
