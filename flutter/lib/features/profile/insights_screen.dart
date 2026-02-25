import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/records_provider.dart';

// 时间范围选择器状态
final timeRangeProvider = StateProvider<int>((ref) => 0); // 0=周, 1=月, 2=年

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);
    final timeRange = ref.watch(timeRangeProvider);
    
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
              _buildTimeSelector(ref, timeRange),
              const SizedBox(height: 32),
              _buildMainChart(context, timeRange),
              const SizedBox(height: 32),
              _buildDimensionAnalysis(context),
              const SizedBox(height: 32),
              _buildAIDeepReview(context, recordsAsync),
              const SizedBox(height: 32),
              _buildMilestones(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '深度洞察',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(WidgetRef ref, int timeRange) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeOption('周', timeRange == 0, () => ref.read(timeRangeProvider.notifier).state = 0),
          _buildTimeOption('月', timeRange == 1, () => ref.read(timeRangeProvider.notifier).state = 1),
          _buildTimeOption('年', timeRange == 2, () => ref.read(timeRangeProvider.notifier).state = 2),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 根据时间范围获取图表标题
  String _getChartTitle(int timeRange) {
    switch (timeRange) {
      case 0:
        return '本周指数趋势';
      case 1:
        return '本月指数趋势';
      case 2:
        return '年度指数趋势';
      default:
        return '指数趋势';
    }
  }

  // 根据时间范围获取底部标题
  List<String> _getBottomTitles(int timeRange) {
    switch (timeRange) {
      case 0:
        return ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      case 1:
        return ['第1周', '第2周', '第3周', '第4周'];
      case 2:
        return ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
      default:
        return [];
    }
  }

  // 根据时间范围生成模拟数据
  List<FlSpot> _generateChartData(int timeRange) {
    switch (timeRange) {
      case 0:
        return [
          const FlSpot(0, 65),
          const FlSpot(1, 72),
          const FlSpot(2, 68),
          const FlSpot(3, 85),
          const FlSpot(4, 80),
          const FlSpot(5, 92),
          const FlSpot(6, 88),
        ];
      case 1:
        return [
          const FlSpot(0, 70),
          const FlSpot(1, 75),
          const FlSpot(2, 68),
          const FlSpot(3, 82),
        ];
      case 2:
        return [
          const FlSpot(0, 60),
          const FlSpot(1, 65),
          const FlSpot(2, 58),
          const FlSpot(3, 70),
          const FlSpot(4, 75),
          const FlSpot(5, 72),
          const FlSpot(6, 80),
          const FlSpot(7, 85),
          const FlSpot(8, 78),
          const FlSpot(9, 82),
          const FlSpot(10, 88),
          const FlSpot(11, 92),
        ];
      default:
        return [];
    }
  }

  Widget _buildMainChart(BuildContext context, int timeRange) {
    final bottomTitles = _getBottomTitles(timeRange);
    final chartData = _generateChartData(timeRange);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getChartTitle(timeRange), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.primary.withOpacity(0.8),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          '指数: ${barSpot.y.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < bottomTitles.length) {
                          return Text(bottomTitles[value.toInt()],
                            style: const TextStyle(color: Colors.white38, fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                        style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionAnalysis(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('多维成长分析', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildDimensionCard('健康', '+5%', AppColors.accent),
            const SizedBox(width: 12),
            _buildDimensionCard('财富', '+12%', AppColors.primary),
            const SizedBox(width: 12),
            _buildDimensionCard('幸福', '-2%', AppColors.secondary),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionCard(String label, String change, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              change,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _generateAIReview(AsyncValue<List<dynamic>> recordsAsync) {
    return recordsAsync.when(
      loading: () => '“正在分析你的记录数据...”',
      error: (_, __) => '“本周你的财富指数增长显著，主要得益于在技术项目上的专注投入。然而，幸福感略有下滑，数据显示这与你社交频率降低及睡眠时间减少呈正相关。建议下周增加至少两次户外社交活动。”',
      data: (records) {
        if (records.isEmpty) {
          return '“开始记录你的生活，让我更好地了解你。每一次记录都是自我认知的开始。”';
        }
        
        final count = records.length;
        if (count < 5) {
          return '“你已经开始了记录之旅！继续保持，记录越多，我越能帮你发现生活中的规律。”';
        } else if (count < 20) {
          return '“本周你保持了良好的记录习惯。通过分析，我发现你在情感表达方面有了明显进步。继续坚持下去！”';
        } else {
          return '“本月你已经记录了 $count 条内容，数据量相当丰富！分析显示你在自我反思方面有了显著提升，幸福感指数呈上升趋势。继续保持！”';
        }
      },
    );
  }

  Widget _buildAIDeepReview(BuildContext context, AsyncValue<List<dynamic>> recordsAsync) {
    final reviewText = _generateAIReview(recordsAsync);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: AppColors.secondary),
              SizedBox(width: 8),
              Text('AI 深度复盘', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            reviewText,
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('本阶段里程碑', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildMilestoneItem('完成记否核心架构搭建', '3天前', Icons.check_circle, AppColors.primary),
        _buildMilestoneItem('连续记录达到 14 天', '昨天', Icons.stars, AppColors.secondary),
      ],
    );
  }

  Widget _buildMilestoneItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.divider),
        ],
      ),
    );
  }
}
