import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'about_screen.dart';
import 'feedback_screen.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMenuSection(context, '账户设置', [
            _MenuItem(Icons.notifications_none, '通知提醒'),
            _MenuItem(Icons.security, '账号安全'),
          ]),
          const SizedBox(height: 32),
          _buildMenuSection(context, '支持', [
            _MenuItem(Icons.help_outline, '帮助中心'),
            _MenuItem(Icons.feedback_outlined, '意见反馈'),
            _MenuItem(Icons.info_outline, '关于记否'),
          ]),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () => _showLogoutDialog(context),
              child: const Text('退出登录', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: Colors.white70, size: 22),
                    title: Text(item.title, style: const TextStyle(fontSize: 15)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                    onTap: () {
                      if (item.title == '关于记否') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                      } else if (item.title == '意见反馈') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
                      } else if (item.title == '帮助中心') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                      } else if (['通知提醒', '账号安全'].contains(item.title)) {
                        // 这里可以跳转到具体的子设置页面，目前先保持原样或弹出提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.title}功能开发中')),
                        );
                      }
                    },
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('退出登录', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('确定要退出登录吗？', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('确定', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;

  _MenuItem(this.icon, this.title);
}
