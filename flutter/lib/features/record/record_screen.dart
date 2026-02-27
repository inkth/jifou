import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ripple_animation.dart';
import '../../core/providers/records_provider.dart';
import '../../models/record_model.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  bool _isRecording = false;
  String _statusText = "说一句今天发生的事";

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _statusText = "正在倾听...";
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _statusText = "正在识别...";
    });
    
    // 模拟语音转文字后的提交
    Future.delayed(const Duration(seconds: 1), () async {
      const mockContent = "今天的心情非常不错，完成了 API 对接。";
      await ref.read(recordsProvider.notifier).addRecord(mockContent, 'voice');
      
      if (mounted) {
        setState(() {
          _statusText = "识别成功，已记录";
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _statusText = "说一句今天发生的事";
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              _statusText,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
                color: _isRecording ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Center(
              child: GestureDetector(
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopRecording(),
                child: RippleAnimation(
                  isAnimating: _isRecording,
                  color: AppColors.primary,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                      boxShadow: _isRecording ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ] : [],
                    ),
                    child: Icon(
                      _isRecording ? Icons.mic : Icons.mic_none,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "长按说话",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "最近记录",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  recordsAsync.when(
                    data: (records) => Column(
                      children: records.take(3).map((RecordModel r) => _buildRecordCard(r)).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) {
                      // 错误时不显示错误信息，而是启动重试机制
                      Future.delayed(const Duration(seconds: 3), () {
                        if (context.mounted) {
                          ref.read(recordsProvider.notifier).fetchRecords();
                        }
                      });
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(RecordModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            record.recordType == 'voice' ? Icons.mic : Icons.notes,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              record.content,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(record.emotionScore * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: record.emotionScore > 0.6 ? AppColors.accent : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
