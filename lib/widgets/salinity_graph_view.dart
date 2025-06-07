import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalinityGraphView extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const SalinityGraphView({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate min and max for Y axis with padding (zoomed out)
    final values = history.map((e) => e['value'] as double).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b)) - 1;
    final maxY = (values.reduce((a, b) => a > b ? a : b)) + 1;

    // For X axis, add a little padding on both sides
    final minX = -1.0;
    final maxX = history.length.toDouble();

    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.onPrimary, // Fond en onPrimary pour contraste
          borderRadius: BorderRadius.circular(16), // Pour un arrondi sympa
        ),
        padding: const EdgeInsets.all(16.0), // Increased padding
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.primary.withOpacity(0.2),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: colorScheme.primary.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: colorScheme.primary, width: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(color: colorScheme.primary),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (history.length / 6).ceilToDouble().clamp(1, 999),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= history.length)
                      return const SizedBox();
                    final date = history[index]['timestamp'] as DateTime;
                    return Text(
                      DateFormat('HH:mm').format(date),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,

              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => colorScheme.onPrimary,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final text = touchedSpot.y.toStringAsFixed(4);
                    return LineTooltipItem(
                      text,
                      TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: colorScheme.primary,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: colorScheme.primary, // Use a contrasting color
                        strokeWidth: 2,
                        strokeColor: colorScheme.primary,
                      ),
                ),

                belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.primary.withOpacity(0.3),
                ),
                spots: history.asMap().entries.map((entry) {
                  final index = entry.key.toDouble();
                  final value = entry.value['value'] as double;
                  return FlSpot(index, value);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
