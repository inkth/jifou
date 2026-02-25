import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于记否'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: const Icon(Icons.psychology, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              '记否',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '记否是一款基于人工智能的个人成长与生活记录助手。我们致力于通过 AI 技术帮助用户更好地记录生活、分析自我、发现规律，从而实现持续的个人成长。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
            ),
            const Spacer(),
            const Text(
              '© 2026 Jifou AI Team',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
