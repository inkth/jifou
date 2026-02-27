from sqlalchemy.orm import Session
from typing import List
from ..schemas.record import RecordCreate
from ..models.models import RecordModel
from .ai_service import ai_service

class RecordService:
    """
    记录业务逻辑类 (数据库持久化版)
    """
    
    async def create_record(self, db: Session, record_in: RecordCreate, user_id: str) -> RecordModel:
        # 1. 调用 AI 服务分析内容
        ai_result = await ai_service.analyze_record(record_in.content)
        
        # 2. 组装数据库模型
        db_record = RecordModel(
            user_id=user_id,
            content=record_in.content,
            record_type=record_in.record_type,
            emotion_score=ai_result["emotion_score"],
            categories=ai_result["categories"]
        )
        
        # 3. 保存到数据库
        db.add(db_record)
        db.commit()
        db.refresh(db_record)
        return db_record

    async def get_recent_records(self, db: Session, user_id: str, limit: int = 10) -> List[RecordModel]:
        return db.query(RecordModel).filter(RecordModel.user_id == user_id).order_by(RecordModel.created_at.desc()).limit(limit).all()

record_service = RecordService()
