import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/fitness_provider.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedPeriod = 0; // 0 for Weekly, 1 for Monthly

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control for Period Selection
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text('Weekly'),
                    icon: Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Performance Overview Card
            _buildOverviewSummaryCard(provider),
            const SizedBox(height: 24),

            // Calories Burned Graph Section
            Text(
              _selectedPeriod == 0 ? 'Weekly Calories Burned (kcal)' : 'Monthly Calories Breakdown',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCaloriesBarChart(context),
            const SizedBox(height: 24),

            // Workout Time Line Graph Section
            Text(
              _selectedPeriod == 0 ? 'Weekly Active Time (mins)' : 'Monthly Active Time Trend',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActiveTimeLineChart(context),
          ],
        ),
      ),
    );
  }

  /// Overview metrics summary cards (Averages)
  Widget _buildOverviewSummaryCard(FitnessProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatMetric('Avg Steps', '7,420', Icons.directions_walk, Colors.indigo),
            _buildStatMetric('Avg Burned', '480 kcal', Icons.local_fire_department, Colors.orange),
            _buildStatMetric('Avg Active', '45 mins', Icons.timer, const Color(0xFF00D1A0)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  /// Calories Burned Bar Chart
  Widget _buildCaloriesBarChart(BuildContext context) {
    final isWeekly = _selectedPeriod == 0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (isWeekly) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt() % days.length], style: const TextStyle(fontSize: 11)),
                    );
                  } else {
                    const weeks = ['W1', 'W2', 'W3', 'W4'];
                    if (value >= 0 && value < weeks.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(weeks[value.toInt()], style: const TextStyle(fontSize: 11)),
                      );
                    }
                    return const Text('');
                  }
                },
              ),
            ),
          ),
          barGroups: isWeekly
              ? [
            _createBarGroup(0, 320),
            _createBarGroup(1, 450),
            _createBarGroup(2, 280),
            _createBarGroup(3, 520),
            _createBarGroup(4, 400),
            _createBarGroup(5, 610),
            _createBarGroup(6, 390),
          ]
              : [
            _createBarGroup(0, 2400),
            _createBarGroup(1, 3100),
            _createBarGroup(2, 2800),
            _createBarGroup(3, 3500),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF6C63FF),
          width: 14,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  /// Active Time Trend Line Chart
  Widget _buildActiveTimeLineChart(BuildContext context) {
    final isWeekly = _selectedPeriod == 0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (isWeekly) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt() % days.length], style: const TextStyle(fontSize: 11)),
                    );
                  } else {
                    const weeks = ['W1', 'W2', 'W3', 'W4'];
                    if (value >= 0 && value < weeks.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(weeks[value.toInt()], style: const TextStyle(fontSize: 11)),
                      );
                    }
                    return const Text('');
                  }
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: isWeekly
                  ? const [
                FlSpot(0, 30),
                FlSpot(1, 45),
                FlSpot(2, 25),
                FlSpot(3, 60),
                FlSpot(4, 40),
                FlSpot(5, 75),
                FlSpot(6, 50),
              ]
                  : const [
                FlSpot(0, 220),
                FlSpot(1, 310),
                FlSpot(2, 270),
                FlSpot(3, 380),
              ],
              isCurved: true,
              color: const Color(0xFF00D1A0),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF00D1A0).withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}