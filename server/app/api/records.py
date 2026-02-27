from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
from ..schemas.record import Record, RecordCreate
from ..services.record_service import record_service
from ..core.database import get_db
from .auth import get_current_user
from ..models.models import UserModel

router = APIRouter(prefix="/records", tags=["records"])

@router.post("/", response_model=Record)
async def create_record(
    record_in: RecordCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user)
):
    """
    创建一条新记录，并持久化到数据库
    """
    return await record_service.create_record(db, record_in, current_user.id)

@router.get("/", response_model=List[Record])
async def get_records(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user)
):
    """
    从数据库获取最近的记录列表
    """
    return await record_service.get_recent_records(db, current_user.id, limit)
