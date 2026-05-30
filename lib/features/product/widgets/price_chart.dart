import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:price_tracker_app/models/price_history_model.dart';

class PriceChart extends StatelessWidget {
  const PriceChart({super.key, required this.history, required this.avgLine});

  final List<PriceHistoryModel> history;
  final double avgLine;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox(height: 220, child: Center(child: Text('No price history')));

    final spots = <FlSpot>[];
    for (var i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].price));
    }

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map(
                    (s) => LineTooltipItem(
                      'NPR ${s.y.toStringAsFixed(0)}
${DateFormat.yMMMd().format(history[s.x.toInt()].timestamp)}',
                      const TextStyle(color: Colors.white),
                    ),
                  )
                  .toList(),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: avgLine, color: Colors.blueGrey, dashArray: [5, 5]),
            ],
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: spots,
              dotData: const FlDotData(show: false),
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
