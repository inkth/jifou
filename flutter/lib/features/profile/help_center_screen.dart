import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助中心'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFaqItem('如何开始记录？', '点击首页底部的“+”按钮，即可开始语音或文字记录。'),
          _buildFaqItem('AI 洞察是如何生成的？', 'AI 会分析您的记录内容，从中提取情感、主题和关键事件，为您提供深度反馈。'),
          _buildFaqItem('我的数据安全吗？', '我们采用端到端加密技术，确保您的个人记录只有您自己可以访问。'),
          _buildFaqItem('如何升级 Pro 会员？', '在“我的”页面点击会员卡片，即可查看会员权益并进行升级。'),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              '还有其他问题？请联系客服',
              style: TextStyle(color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}
