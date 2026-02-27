import json
import random
from typing import List, Dict, Any
from openai import AsyncOpenAI
from ..schemas.record import RecordCreate
from ..models.models import RecordModel
from ..core.config import settings

class AIService:
    """
    AI 服务类，负责与 LLM 交互进行情绪分析和分类
    """
    
    def __init__(self):
        if settings.OPENROUTER_API_KEY:
            self.client = AsyncOpenAI(
                api_key=settings.OPENROUTER_API_KEY,
                base_url=settings.OPENROUTER_BASE_URL,
                default_headers={
                    "HTTP-Referer": settings.SITE_URL,
                    "X-Title": settings.SITE_NAME,
                }
            )
        elif settings.OPENAI_API_KEY:
            self.client = AsyncOpenAI(
                api_key=settings.OPENAI_API_KEY,
                base_url=settings.OPENAI_API_BASE
            )
        else:
            self.client = None

    async def analyze_record(self, content: str) -> Dict[str, Any]:
        """
        分析记录内容，返回情绪评分和分类
        """
        if not self.client:
            return self._mock_analyze_record(content)

        try:
            prompt = f"""
            分析以下用户记录，给出 0-1 的情绪评分（0为极度负面，1为极度正面），并从 [health, wealth, happiness] 中选择一个或多个分类。
            请以 JSON 格式返回，例如: {{"emotion_score": 0.8, "categories": ["happiness"]}}
            
            用户记录: "{content}"
            """
            
            response = await self.client.chat.completions.create(
                model=settings.AI_MODEL,
                messages=[{{"role": "user", "content": prompt}}],
                response_format={{"type": "json_object"}}
            )
            
            result = json.loads(response.choices[0].message.content)
            return {{
                "emotion_score": result.get("emotion_score", 0.5),
                "categories": result.get("categories", ["happiness"])
            }}
        except Exception as e:
            print(f"AI Analysis Error: {e}")
            return self._mock_analyze_record(content)

    async def generate_daily_report(self, records: List[RecordModel]) -> Dict[str, Any]:
        """
        聚合全天记录生成人生报告
        """
        if not records:
            return None

        if not self.client:
            return self._mock_generate_daily_report(records)

        try:
            combined_content = "\n".join([f"- {r.content}" for r in records])
            prompt = f"""
            以下是用户今天的记录：
            {combined_content}
            
            请生成一份人生报告，包含以下字段的 JSON 格式：
            - life_index: 人生指数 (0-100)
            - health_score: 健康评分 (0-100)
            - wealth_score: 财富评分 (0-100)
            - happiness_score: 幸福评分 (0-100)
            - summary: 今日总结 (一句话)
            - analysis: 深度解析 (一段话)
            - risk_warning: 风险提示 (一句话)
            - advice: 明日建议 (一句话)
            """
            
            response = await self.client.chat.completions.create(
                model=settings.AI_MODEL,
                messages=[{{"role": "user", "content": prompt}}],
                response_format={{"type": "json_object"}}
            )
            
            return json.loads(response.choices[0].message.content)
        except Exception as e:
            print(f"AI Report Generation Error: {e}")
            return self._mock_generate_daily_report(records)

    def _mock_analyze_record(self, content: str) -> Dict[str, Any]:
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

    def _mock_generate_daily_report(self, records: List[RecordModel]) -> Dict[str, Any]:
        avg_emotion = sum([r.emotion_score for r in records]) / len(records)
        life_index = int(avg_emotion * 100)
        return {
            "life_index": life_index,
            "health_score": 70 + random.randint(0, 20),
            "wealth_score": 60 + random.randint(0, 30),
            "happiness_score": 80 + random.randint(0, 15),
            "summary": f"今天你记录了 {len(records)} 件事。整体情绪表现稳定。",
            "analysis": "从记录来看，你的生活节奏把握得不错。",
            "risk_warning": "注意保持规律作息。",
            "advice": "明天继续保持积极的心态。"
        }

ai_service = AIService()
