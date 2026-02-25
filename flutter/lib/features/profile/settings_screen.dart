import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final String title;
  const SettingsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingItem(context, '选项一', true),
          _buildSettingItem(context, '选项二', false),
          _buildSettingItem(context, '选项三', true),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              '更多设置项正在开发中...',
              style: TextStyle(color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String label, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
