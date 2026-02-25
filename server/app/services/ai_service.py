import json
from typing import List, Dict, Any
from ..schemas.record import RecordCreate, RecordType
from ..models.models import RecordModel
import random

class AIService:
    """
    AI 服务类，负责与 LLM 交互进行情绪分析和分类
    """
    
    async def analyze_record(self, content: str) -> Dict[str, Any]:
        """
        分析记录内容，返回情绪评分和分类
        在生产环境中，这里会调用 OpenAI 或 Claude API
        """
        # 模拟 AI 处理延迟
        # await asyncio.sleep(1) 
        
        # 这是一个示例 Prompt 逻辑的输出
        # Prompt: "分析以下用户记录，给出 0-1 的情绪评分，并从 [health, wealth, happiness] 中选择分类"
        
        # 简单的模拟逻辑
        emotion_score = 0.5 + (random.random() * 0.5) if "好" in content or "棒" in content else 0.3 + (random.random() * 0.4)
        
        categories = []
        if any(word in content for word in ["钱", "工作", "加班", "项目", "财富"]):
            categories.append("wealth")
        if any(word in content for word in ["健身", "累", "舒服", "病", "健康", "跑"]):
            categories.append("health")
        if not categories:
            categories.append("happiness")
            
        return {
            "emotion_score": round(emotion_score, 2),
            "categories": categories
        }

    async def generate_daily_report(self, records: List[RecordModel]) -> Dict[str, Any]:
        """
        聚合全天记录生成人生报告
        """
        if not records:
            return None

        # 提取所有记录内容
        combined_content = "\n".join([f"- {r.content}" for r in records])
        
        # 模拟 AI 聚合逻辑
        # Prompt: "以下是用户今天的记录：{combined_content}。请生成一份人生报告，包含人生指数(0-100)、健康/财富/幸福评分、总结、解析、风险提示和明日建议。"
        
        # 计算平均情绪分作为参考
        avg_emotion = sum([r.emotion_score for r in records]) / len(records)
        life_index = int(avg_emotion * 100)

        return {
            "life_index": life_index,
            "health_score": 70 + random.randint(0, 20),
            "wealth_score": 60 + random.randint(0, 30),
            "happiness_score": 80 + random.randint(0, 15),
            "summary": f"今天你记录了 {len(records)} 件事。整体情绪表现稳定，你在多个领域都有所进展。",
            "analysis": "从记录来看，你的幸福感主要来源于成就感，而健康方面仍有提升空间。",
            "risk_warning": "连续的思考可能导致大脑疲劳，建议增加体力活动。",
            "advice": "明天可以尝试将一个大任务拆解，并安排一段完全放松的时间。"
        }

ai_service = AIService()
