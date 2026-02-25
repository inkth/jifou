from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api import records, reports
from .core.database import engine, Base

# 创建数据库表 (MVP 阶段简单处理，生产环境建议使用 Alembic)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="记否 API",
    description=" MVP 后端",
    version="1.0.0",
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # MVP 阶段允许所有来源，生产环境需限制
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "Welcome to Jifou AI API",
        "status": "online",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

app.include_router(records.router)
app.include_router(reports.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
