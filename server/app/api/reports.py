from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import date
from ..schemas.report import DailyReport
from ..services.report_service import report_service
from ..core.database import get_db

router = APIRouter(prefix="/reports", tags=["reports"])

@router.get("/daily/{target_date}", response_model=DailyReport)
async def get_daily_report(target_date: date, db: Session = Depends(get_db)):
    """
    获取指定日期的每日报告。如果报告不存在且有记录，则触发 AI 生成。
    """
    report = await report_service.get_or_generate_daily_report(db, target_date)
    if not report:
        raise HTTPException(status_code=404, detail="该日期没有记录，无法生成报告")
    return report
