import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'feedback_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildUserInfo(context),
              const SizedBox(height: 40),
              _buildMembershipCard(context),
              const SizedBox(height: 40),
              _buildMenuSection(context, '账户设置', [
                _MenuItem(Icons.person_outline, '个人资料'),
                _MenuItem(Icons.notifications_none, '通知提醒'),
                _MenuItem(Icons.security, '账号安全'),
              ]),
              const SizedBox(height: 32),
              _buildMenuSection(context, '通用', [
                _MenuItem(Icons.dark_mode_outlined, '外观主题'),
                _MenuItem(Icons.cloud_upload_outlined, '数据同步'),
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
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Roo Engineer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: 10242048',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro 会员',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '解锁无限 AI 洞察与电台内容',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showComingSoonSnackBar(context, '会员续费'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('续费', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能开发中...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
              _showComingSoonSnackBar(context, '退出登录');
            },
            child: const Text('确定', style: TextStyle(color: Colors.redAccent)),
          ),
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
                      } else if (item.title == '个人资料') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                      } else if (item.title == '意见反馈') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
                      } else if (item.title == '帮助中心') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                      } else if (['通知提醒', '账号安全', '外观主题', '数据同步'].contains(item.title)) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(title: item.title)));
                      } else {
                        _showComingSoonSnackBar(context, item.title);
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
}

class _MenuItem {
  final IconData icon;
  final String title;

  _MenuItem(this.icon, this.title);
}
