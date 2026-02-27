import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class DiscoveryItem {
  final String title;
  final String content;
  final String imageUrl;
  final String audioUrl;
  final Duration duration;
  final String category;

  DiscoveryItem({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    required this.category,
  });
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _waveController;
  Timer? _progressTimer;
  bool _isPlaying = false;
  double _playProgress = 0.0;
  String _selectedCategory = '全部';

  final List<String> _categories = ['全部', '健康', '财富', '幸福', '收藏'];

  final List<DiscoveryItem> _allItems = [
    DiscoveryItem(
      title: '如何通过微习惯改变人生？',
      content: '来自《原子习惯》的深度解读。微习惯是一种非常微小的正面行为，你每天强迫自己完成它。它的力量在于“微小”，让你无法拒绝。',
      imageUrl: 'https://images.unsplash.com/photo-1506784919141-177b7ec8ee0f?w=800&q=80',
      audioUrl: 'mock_audio_1',
      duration: const Duration(minutes: 3, seconds: 45),
      category: '幸福',
    ),
    DiscoveryItem(
      title: '冥想：找回内心的平静',
      content: '10分钟引导式音频课程。在繁忙的生活中，给自己留出一点时间，观察呼吸，觉察当下，找回那份久违的宁静。',
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80',
      audioUrl: 'mock_audio_2',
      duration: const Duration(minutes: 10, seconds: 0),
      category: '健康',
    ),
    DiscoveryItem(
      title: '深度工作的艺术',
      content: '在嘈杂的世界中保持专注。深度工作是指在无干扰的状态下专注进行职业活动，使个人的认知能力达到极限。',
      imageUrl: 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&q=80',
      audioUrl: 'mock_audio_3',
      duration: const Duration(minutes: 5, seconds: 20),
      category: '财富',
    ),
    DiscoveryItem(
      title: '高效睡眠的秘密',
      content: '如何通过科学的方法提高睡眠质量。睡眠不仅是休息，更是大脑排毒和记忆巩固的关键过程。',
      imageUrl: 'https://images.unsplash.com/photo-1511295742364-91190082d103?w=800&q=80',
      audioUrl: 'mock_audio_4',
      duration: const Duration(minutes: 4, seconds: 15),
      category: '健康',
    ),
  ];

  List<DiscoveryItem> get _filteredItems {
    if (_selectedCategory == '全部') return _allItems;
    if (_selectedCategory == '收藏') return _allItems.take(1).toList(); // 模拟收藏
    return _allItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startPlayback();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _waveController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startPlayback() {
    if (_filteredItems.isEmpty) return;
    
    _stopPlayback();
    
    setState(() {
      _isPlaying = true;
      _waveController.repeat();
    });
    
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _playProgress += 0.002;
      });
      
      if (_playProgress >= 1.0) {
        _progressTimer?.cancel();
        _progressTimer = null;
        setState(() {
          _playProgress = 0.0;
          _isPlaying = false;
          _waveController.stop();
        });
      }
    });
  }

  void _stopPlayback() {
    _progressTimer?.cancel();
    _progressTimer = null;
    setState(() {
      _isPlaying = false;
      _waveController.stop();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _playProgress = 0.0;
    });
    _startPlayback();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildCategoryBar(),
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(child: Text('暂无内容', style: TextStyle(color: Colors.white54)))
                  : PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      onPageChanged: _onPageChanged,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.1)).clamp(0.8, 1.0);
                            }
                            return Center(
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.7,
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: Transform.scale(
                                  scale: value,
                                  child: _buildDiscoveryCard(_filteredItems[index]),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              if (category == '收藏') {
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
                  return;
                }
              }
              setState(() {
                _selectedCategory = category;
                _playProgress = 0.0;
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
              });
              _startPlayback();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              child: Column(
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryCard(DiscoveryItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 64),
              );
            },
          ),
          // 渐变遮罩
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // 进度条
                Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppColors.primary,
                      ),
                      child: Slider(
                        value: _playProgress,
                        onChanged: (value) {
                          setState(() {
                            _playProgress = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(item.duration * _playProgress),
                            style: const TextStyle(color: Colors.white54, fontSize: 10),
                          ),
                          Text(
                            _formatDuration(item.duration),
                            style: const TextStyle(color: Colors.white54, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _playProgress = (_playProgress - 0.05).clamp(0.0, 1.0);
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        if (_isPlaying) {
                          _stopPlayback();
                        } else {
                          _startPlayback();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _playProgress = (_playProgress + 0.05).clamp(0.0, 1.0);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 波形指示器
                Center(
                  child: _buildWaveform(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(12, (index) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            final double height = _isPlaying 
                ? 4 + (16 * (0.5 + 0.5 * (index % 3 == 0 ? _waveController.value : (index % 3 == 1 ? 1.0 - _waveController.value : 0.5))))
                : 4;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          },
        );
      }),
    );
  }
}
