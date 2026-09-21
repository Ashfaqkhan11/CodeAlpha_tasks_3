import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/fitness_provider.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final stepProgress = (provider.stepCount / provider.stepGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Chip(
            avatar: const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
            label: const Text('5 Day Streak'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cards & Circular Progress
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularPercentIndicator(
                      radius: 55.0,
                      lineWidth: 10.0,
                      percent: stepProgress,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${provider.stepCount}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Text('Steps', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      progressColor: const Color(0xFF6C63FF),
                      backgroundColor: Colors.grey.shade200,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricTile(Icons.local_fire_department, '${provider.todayCalories} / ${provider.calorieGoal} kcal', 'Calories'),
                        const SizedBox(height: 12),
                        _buildMetricTile(Icons.timer, '${provider.todayWorkoutMinutes} mins', 'Active Time'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weekly Chart Section
            const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Text(days[value.toInt() % days.length]);
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 6, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 9, color: const Color(0xFF00D1A0))]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 7, color: const Color(0xFF6C63FF))]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: const Color(0xFF00D1A0))]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 4, color: const Color(0xFF6C63FF))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Activities List
            const Text('Recent Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            provider.activities.isEmpty
                ? const Center(child: Text('No activities logged yet.'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.activities.length > 5 ? 5 : provider.activities.length,
              itemBuilder: (ctx, index) {
                final item = provider.activities[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      child: const Icon(Icons.fitness_center, color: Color(0xFF6C63FF)),
                    ),
                    title: Text(item.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.duration} mins • ${item.calories} kcal'),
                    trailing: Text('${item.date.day}/${item.date.month}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, String value, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }
}