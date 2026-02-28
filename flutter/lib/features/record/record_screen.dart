import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  late stt.SpeechToText _speech;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startRecording() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (errorNotification) => debugPrint('Speech error: $errorNotification'),
    );

    if (available) {
      setState(() {
        _isRecording = true;
        _statusText = "正在倾听...";
        _lastWords = '';
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            if (_lastWords.isNotEmpty) {
              _statusText = _lastWords;
            }
          });
        },
        localeId: 'zh_CN',
      );
    } else {
      setState(() {
        _statusText = "语音识别不可用，请检查权限";
      });
    }
  }

  Future<void> _stopRecording() async {
    await _speech.stop();
    setState(() {
      _isRecording = false;
      _statusText = _lastWords.isNotEmpty ? "正在记录..." : "未识别到语音";
    });

    if (_lastWords.isNotEmpty) {
      await ref.read(recordsProvider.notifier).addRecord(_lastWords, 'voice');
      if (mounted) {
        setState(() {
          _statusText = "记录成功";
        });
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _statusText = "说一句今天发生的事";
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
