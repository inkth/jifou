import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/starry_background.dart';
import '../../core/widgets/ripple_animation.dart';
import '../../core/providers/records_provider.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../models/record_model.dart';
import 'widgets/mini_game_card.dart';
import '../auth/login_screen.dart';
import '../../core/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isRecording = false;
  int _currentPromptIndex = 0;
  late Timer _promptTimer;
  
  // 语音识别相关
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _recordingText = '正在倾听你的此刻...';
  
  // 图片选择器
  final ImagePicker _imagePicker = ImagePicker();
  
  // 文字输入控制器
  final TextEditingController _textController = TextEditingController();

  final List<String> _prompts = [
    '此刻的心情如何？',
    '今天有什么值得记录的瞬间？',
    '有什么想对自己说的吗？',
    '捕捉一个灵感...',
    '现在最想感谢谁？',
  ];

  @override
  void initState() {
    super.initState();
    _startPromptTimer();
    _initSpeech();
  }

  @override
  void dispose() {
    _promptTimer.cancel();
    _textController.dispose();
    super.dispose();
  }

  bool _checkAuth() {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const FractionallySizedBox(
          heightFactor: 0.9,
          child: LoginScreen(),
        ),
      );
      return false;
    }
    return true;
  }

  // 初始化语音识别
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('语音识别错误: $error'),
      onStatus: (status) => print('语音识别状态: $status'),
    );
    setState(() {});
  }

  // 开始语音识别
  void _startListening() async {
    if (!_checkAuth()) return;
    
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('语音识别暂不可用，请检查权限设置')),
      );
      return;
    }
    _lastWords = '';
    await _speechToText.listen(
      onResult: (result) => _onSpeechResult(result),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
      localeId: 'zh_CN',
    );
    setState(() {
      _isRecording = true;
    });
  }

  // 停止语音识别
  void _stopListening() async {
    if (!_isRecording) return;
    
    await _speechToText.stop();
    setState(() {
      _isRecording = false;
    });
    // 如果有识别到的文字，保存记录
    if (_lastWords.isNotEmpty) {
      await ref.read(recordsProvider.notifier).addRecord(_lastWords, 'voice');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('语音已记录')),
        );
      }
    }
  }

  // 处理语音识别结果
  void _onSpeechResult(dynamic result) {
    setState(() {
      _lastWords = result.recognizedWords as String;
      _recordingText = result.finalResult as bool
          ? '识别完成'
          : '正在识别: ${result.recognizedWords}';
    });
  }

  // 拍照功能
  Future<void> _takePhoto() async {
    if (!_checkAuth()) return;
    
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        await ref.read(recordsProvider.notifier).addRecord(
          '[图片] ${photo.path}',
          'image',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('照片已保存')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  // 从相册选择图片
  Future<void> _pickFromGallery() async {
    if (!_checkAuth()) return;
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        await ref.read(recordsProvider.notifier).addRecord(
          '[图片] ${image.path}',
          'image',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图片已保存')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  // 文字输入功能
  void _showTextInputDialog() {
    if (!_checkAuth()) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '记录此刻',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 5,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '写下此刻的想法...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_textController.text.trim().isNotEmpty) {
                    await ref.read(recordsProvider.notifier).addRecord(
                      _textController.text.trim(),
                      'text',
                    );
                    _textController.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('文字已记录')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 拍照按钮点击处理（显示选择器）
  void _handleCameraTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('拍照', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('从相册选择', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startPromptTimer() {
    _promptTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentPromptIndex = (_currentPromptIndex + 1) % _prompts.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);
    
    return Scaffold(
      body: StarryBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      _buildMinimalHeader(),
                      const SizedBox(height: 32),
                      const MiniGameCard(),
                      const SizedBox(height: 32),
                      _buildRecentRecordsSection(recordsAsync),
                    ],
                  ),
                ),
              ),
              _buildIntegratedRecordArea(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRecordsSection(AsyncValue<List<RecordModel>> recordsAsync) {
    return recordsAsync.when(
      loading: () => Column(
        children: List.generate(3, (index) => const RecordSkeleton()),
      ),
      error: (error, stack) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                const SizedBox(height: 12),
                Text(
                  '加载失败: $error',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => ref.read(recordsProvider.notifier).fetchRecords(),
                  child: const Text('重试', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      },
      data: (records) {
        if (records.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                '还没有记录，\n开始记录你的第一个此刻吧',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.6),
              ),
            ),
          );
        }
        
        // 只显示最近 5 条记录
        final recentRecords = records.take(5).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近记录',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '共 ${records.length} 条',
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentRecords.map((record) => _buildRecordItem(record)),
          ],
        );
      },
    );
  }

  Widget _buildRecordItem(dynamic record) {
    final content = record.content as String;
    final type = record.recordType as String;
    final createdAt = record.createdAt as DateTime;
    
    // 获取类型图标和颜色
    IconData typeIcon;
    Color typeColor;
    String typeLabel;
    
    switch (type) {
      case 'voice':
        typeIcon = Icons.mic;
        typeColor = AppColors.primary;
        typeLabel = '语音';
        break;
      case 'image':
        typeIcon = Icons.image;
        typeColor = AppColors.secondary;
        typeLabel = '图片';
        break;
      default:
        typeIcon = Icons.edit;
        typeColor = Colors.white54;
        typeLabel = '文字';
    }
    
    // 格式化时间
    final timeStr = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: typeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.length > 50 ? '${content.substring(0, 50)}...' : content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      timeStr,
                      style: const TextStyle(color: Colors.white24, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(color: typeColor, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  Widget _buildMinimalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getFormattedDate(),
          style: const TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Text(
          '此刻记否',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
        ),
      ],
    );
  }

  Widget _buildPromptBubble() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isRecording ? 0.0 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _prompts[_currentPromptIndex],
              key: ValueKey<int>(_currentPromptIndex),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntegratedRecordArea() {
    return Column(
      children: [
        _buildPromptBubble(),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSideButton(
              Icons.edit_note_rounded,
              '文字',
              _showTextInputDialog,
            ),
            const SizedBox(width: 32),
            _buildMainRecordButton(),
            const SizedBox(width: 32),
            _buildSideButton(
              Icons.camera_alt_rounded,
              '拍照',
              _handleCameraTap,
            ),
          ],
        ),
        const SizedBox(height: 32),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isRecording ? 1.0 : 0.5,
          child: Text(
            _lastWords.isNotEmpty && _isRecording
                ? _recordingText
                : (_isRecording ? '正在倾听你的此刻...' : '长按语音记录此刻'),
            style: TextStyle(
              color: _isRecording ? AppColors.primary : Colors.white38,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildMainRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) {
        HapticFeedback.heavyImpact();
        _startListening();
      },
      onLongPressEnd: (_) {
        HapticFeedback.mediumImpact();
        _stopListening();
      },
      onTap: () {
        HapticFeedback.lightImpact();
        // 快速点击开始录音
        _startListening();
      },
      child: RippleAnimation(
        isAnimating: _isRecording,
        color: AppColors.primary,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}
