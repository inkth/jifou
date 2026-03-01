import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/records_provider.dart';
import '../../models/record_model.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);
    final authState = ref.watch(authProvider);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 340,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderBackground(context, authState),
                  collapseMode: CollapseMode.pin,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  if (authState.isAuthenticated)
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                      },
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: _buildStatsRow(recordsAsync),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        indicatorColor: AppColors.primary,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        tabs: const [
                          Tab(text: '人生记录'),
                          Tab(text: '我的卡片'),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildLifePathTab(),
              _buildCardsTab(recordsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context, AuthState authState) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景装饰
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        border: Border.all(color: Colors.white24, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  if (authState.isAuthenticated)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('编辑资料'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                authState.isAuthenticated ? (authState.user?['full_name'] ?? '用户') : '未登录',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                authState.isAuthenticated 
                    ? '探索内心世界，记录成长点滴。' 
                    : '登录后可将记录同步至云端，永不丢失。',
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
              if (!authState.isAuthenticated)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('立即登录'),
                  ),
                ),
              const SizedBox(height: 16),
              if (authState.isAuthenticated)
                Row(
                  children: [
                    _buildTag('Pro 会员', const Color(0xFFD4AF37)),
                    const SizedBox(width: 8),
                    _buildTag('记录达人', AppColors.primary),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatsRow(AsyncValue<List<RecordModel>> recordsAsync) {
    final count = recordsAsync.maybeWhen(
      data: (records) => records.length.toString(),
      orElse: () => '0',
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('850', '记豆'),
          _buildStatItem('12', '记录'),
          _buildStatItem(count, '卡片'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCardsTab(AsyncValue<List<RecordModel>> recordsAsync) {
    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, stack) => const Center(child: Text('暂无卡片', style: TextStyle(color: Colors.white54))),
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('暂无卡片', style: TextStyle(color: Colors.white54)));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildRecordCard(record);
          },
        );
      },
    );
  }

  Widget _buildRecordCard(RecordModel record) {
    // 模拟背景图，如果有图片记录则使用图片，否则根据类型分配
    String imageUrl = 'https://images.unsplash.com/photo-1506784919141-177b7ec8ee0f?w=800&q=80';
    if (record.recordType == 'image' && record.content.contains('http')) {
      // 简单处理图片链接
      imageUrl = record.content.split(' ').last;
    } else if (record.recordType == 'voice') {
      imageUrl = 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80';
    } else if (record.categories.contains('财富')) {
      imageUrl = 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&q=80';
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      record.recordType == 'voice' ? Icons.mic : (record.recordType == 'image' ? Icons.image : Icons.edit),
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(record.createdAt),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    if (!record.isSynced)
                      const Icon(Icons.sync_problem, color: Colors.orangeAccent, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  record.content.length > 60 ? '${record.content.substring(0, 60)}...' : record.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifePathTab() {
    final List<Map<String, String>> lifePathItems = [
      {
        'date': '2024-02-28',
        'title': '灵感涌现的一天',
        'content': '今天你在清晨记录了一段关于未来城市的构想，AI 感受到你内心深处对科技与自然和谐共生的向往。',
        'type': 'insight',
      },
      {
        'date': '2024-02-25',
        'title': '情绪的起伏',
        'content': '连续三天的深夜记录显示你近期压力较大，建议适当放松，听听轻音乐。',
        'type': 'mood',
      },
      {
        'date': '2024-02-20',
        'title': '突破自我',
        'content': '你完成了一次长达 30 分钟的语音随笔，这是你记录以来最长的一次，展现了极强的表达欲。',
        'type': 'achievement',
      },
      {
        'date': '2024-02-15',
        'title': '财富观的转变',
        'content': '通过对多篇财富类记录的分析，AI 发现你开始从关注短期收益转向长期价值投资。',
        'type': 'wealth',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: lifePathItems.length,
      itemBuilder: (context, index) {
        return _buildLifePathItem(lifePathItems[index], index == lifePathItems.length - 1);
      },
    );
  }

  Widget _buildLifePathItem(Map<String, String> item, bool isLast) {
    IconData icon;
    Color color;
    switch (item['type']) {
      case 'insight':
        icon = Icons.lightbulb_outline;
        color = Colors.amber;
        break;
      case 'mood':
        icon = Icons.favorite_border;
        color = Colors.pinkAccent;
        break;
      case 'achievement':
        icon = Icons.emoji_events_outlined;
        color = Colors.orangeAccent;
        break;
      case 'wealth':
        icon = Icons.account_balance_wallet_outlined;
        color = Colors.greenAccent;
        break;
      default:
        icon = Icons.auto_awesome_outlined;
        color = AppColors.primary;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white10,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      item['date']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(
                    item['content']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
