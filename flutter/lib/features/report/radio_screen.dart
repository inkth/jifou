import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  
  // 播放状态
  bool _isPlaying = false;
  double _playProgress = 0.0;
  
  // 模拟播放进度
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _waveController.repeat();
        _startProgressSimulation();
      } else {
        _waveController.stop();
      }
    });
  }
  
  void _startProgressSimulation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted || !_isPlaying) {
        return false;
      }
      if (_playProgress >= 1.0) {
        setState(() {
          _playProgress = 0.0;
          _isPlaying = false;
          _waveController.stop();
        });
        return false;
      }
      setState(() {
        _playProgress += 0.005;
      });
      return _isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

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
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildAIBroadcast(context),
              const SizedBox(height: 32),
              _buildSectionTitle('成长灵感'),
              const SizedBox(height: 16),
              _buildInspirationCard(
                context,
                '如何通过微习惯改变人生？',
                '来自《原子习惯》的深度解读',
                Icons.menu_book,
                AppColors.primary,
              ),
              const SizedBox(height: 16),
              _buildInspirationCard(
                context,
                '冥想：找回内心的平静',
                '10分钟引导式音频课程',
                Icons.self_improvement,
                AppColors.secondary,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFormattedDate(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI 电台',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildAIBroadcast(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Icon(
                      Icons.graphic_eq,
                      color: Colors.white.withOpacity(0.5 + (_waveController.value * 0.5)),
                      size: 20 + (_waveController.value * 4),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日 AI 播报',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      _isPlaying ? '正在播放...' : '3:45 • 已为你生成',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWaveform(),
          const SizedBox(height: 16),
          // 播放进度条
          if (_isPlaying || _playProgress > 0)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _playProgress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.8)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration((_playProgress * 225).toInt()), // 3:45 = 225秒
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    Text(
                      _formatDuration(225),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 16),
          const Text(
            '“嘿！根据你今天的记录，我发现你在财富维度的投入非常高效。但在健康方面，你的久坐时间超过了4小时...”',
            style: TextStyle(color: Colors.white70, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            final double height = 10 + (15 * (1.0 - (index - 7).abs() / 7.0) *
                (0.5 + 0.5 * (index % 2 == 0 ? _waveController.value : 1.0 - _waveController.value)));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInspirationCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }


}
