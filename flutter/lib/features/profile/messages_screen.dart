import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'message_detail_screen.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: !authState.isAuthenticated
                  ? _buildLoginPrompt(context)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: [
                        _buildMessageItem(
                          context,
                          '系统通知',
                          '欢迎来到记否！开始记录你的第一条生活感悟吧。',
                          '10:30',
                          Icons.campaign,
                          AppColors.primary,
                          isUnread: true,
                        ),
                  _buildMessageItem(
                    context,
                    'AI 助手',
                    '根据你昨天的记录，我为你生成了一份新的成长建议，快去看看吧。',
                    '昨天',
                    Icons.psychology,
                    AppColors.secondary,
                  ),
                  _buildMessageItem(
                    context,
                    '成就达成',
                    '恭喜！你已连续记录 7 天，获得“坚持不懈”卡片。',
                    '2天前',
                    Icons.emoji_events,
                    AppColors.accent,
                  ),
                  _buildMessageItem(
                    context,
                    '未来模拟 Agent',
                    '基于你当前的状态，我为你模拟了三种可能的未来发展路径，点击查看详情。',
                    '3天前',
                    Icons.auto_graph,
                    const Color(0xFFF472B6), // 粉色
                  ),
                  _buildMessageItem(
                    context,
                    '人生复盘 Agent',
                    '本周复盘报告已生成。你在情绪管理和目标达成方面有显著进步。',
                    '本周',
                    Icons.history_edu,
                    const Color(0xFF60A5FA), // 浅蓝
                  ),
                  _buildMessageItem(
                    context,
                    '注意力管理 Agent',
                    '检测到你最近的深度工作时间有所下降，建议尝试番茄工作法。',
                    '1小时前',
                    Icons.track_changes,
                    const Color(0xFFFB923C), // 橙色
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '登录查看消息',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '登录后即可接收系统通知、AI 助手建议以及更多精彩内容。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FractionallySizedBox(
                    heightFactor: 0.9,
                    child: LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('立即登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '消息',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.done_all, color: Colors.white70),
            tooltip: '全部已读',
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color, {
    bool isUnread = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailScreen(
              title: title,
              content: subtitle,
              time: time,
              icon: icon,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: isUnread ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
