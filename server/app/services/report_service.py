from sqlalchemy.orm import Session
from datetime import date, datetime, time
from typing import Optional
from ..models.models import DailyReportModel, RecordModel
from .ai_service import ai_service

class ReportService:
    """
    报告业务逻辑类
    """
    
    async def get_or_generate_daily_report(self, db: Session, target_date: date) -> Optional[DailyReportModel]:
        # 1. 检查是否已存在报告
        existing_report = db.query(DailyReportModel).filter(DailyReportModel.date == target_date).first()
        if existing_report:
            return existing_report
            
        # 2. 获取该日期的所有记录
        start_of_day = datetime.combine(target_date, time.min)
        end_of_day = datetime.combine(target_date, time.max)
        
        records = db.query(RecordModel).filter(
            RecordModel.created_at >= start_of_day,
            RecordModel.created_at <= end_of_day
        ).all()
        
        if not records:
            return None
            
        # 3. 调用 AI 生成报告内容
        ai_report = await ai_service.generate_daily_report(records)
        
        # 4. 保存报告到数据库
        new_report = DailyReportModel(
            date=target_date,
            life_index=ai_report["life_index"],
            health_score=ai_report["health_score"],
            wealth_score=ai_report["wealth_score"],
            happiness_score=ai_report["happiness_score"],
            summary=ai_report["summary"],
            analysis=ai_report["analysis"],
            risk_warning=ai_report["risk_warning"],
            advice=ai_report["advice"]
        )
        
        db.add(new_report)
        db.commit()
        db.refresh(new_report)
        return new_report

report_service = ReportService()
