from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt, JWTError
from ..core.database import get_db
from ..core.config import settings
from ..core.security import create_access_token
from ..models.models import UserModel
from ..schemas.user import User, Token, TokenData, OTPRequest, OTPVerify
import random

router = APIRouter(tags=["auth"])

# Mock OTP storage: phone_number -> code
otp_storage = {}

async def get_current_user(db: Session = Depends(get_db), token: str = str(Depends(settings.oauth2_scheme)) if hasattr(settings, 'oauth2_scheme') else None) -> UserModel:
    # Fallback if oauth2_scheme is not in settings
    from fastapi.security import OAuth2PasswordBearer
    oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")
    
    token_val = token
    if not token_val:
        # This is a bit hacky but depends on how it's called
        raise HTTPException(status_code=401, detail="Not authenticated")

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token_val, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        phone_number: str = payload.get("sub")
        if phone_number is None:
            raise credentials_exception
        token_data = TokenData(phone_number=phone_number)
    except JWTError:
        raise credentials_exception
    user = db.query(UserModel).filter(UserModel.phone_number == token_data.phone_number).first()
    if user is None:
        raise credentials_exception
    return user

@router.post("/send-otp")
async def send_otp(request: OTPRequest):
    # In a real app, send SMS here
    code = str(random.randint(100000, 999999))
    otp_storage[request.phone_number] = code
    print(f"OTP for {request.phone_number}: {code}")
    return {"message": "OTP sent successfully", "code": code} # Returning code for testing convenience

@router.post("/login", response_model=Token)
async def login(verify_data: OTPVerify, db: Session = Depends(get_db)):
    # Verify OTP
    stored_code = otp_storage.get(verify_data.phone_number)
    if not stored_code or stored_code != verify_data.code:
        # For development, allow 123456
        if verify_data.code != "123456":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect verification code",
            )
    
    # Get or create user
    user = db.query(UserModel).filter(UserModel.phone_number == verify_data.phone_number).first()
    if not user:
        user = UserModel(
            phone_number=verify_data.phone_number,
            full_name=f"User_{verify_data.phone_number[-4:]}"
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # Clear OTP
    if verify_data.phone_number in otp_storage:
        del otp_storage[verify_data.phone_number]

    return {
        "access_token": create_access_token(subject=user.phone_number),
        "token_type": "bearer",
    }

@router.get("/me", response_model=User)
async def read_users_me(db: Session = Depends(get_db), token: str = Depends(OAuth2PasswordBearer(tokenUrl="auth/login"))):
    # Re-implementing get_current_user logic here for simplicity or use a proper dependency
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        phone_number: str = payload.get("sub")
        if phone_number is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(UserModel).filter(UserModel.phone_number == phone_number).first()
    if user is None:
        raise credentials_exception
    return user
