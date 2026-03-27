import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/patient.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<DataProvider>().currentPatient;
    if (patient == null) return const Center(child: Text('No data'));

    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final chartHeight = isTablet ? 320.0 : 240.0;

    final history = patient.heartRateHistory;
    final spots = List.generate(history.length, (index) {
      return FlSpot(index.toDouble(), history[index].bpm.toDouble());
    });

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            title: 'Heart Rate Trends',
            subtitle: 'Monitor variance, spikes, and rhythm consistency over time.',
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  minY: 40,
                  maxY: 180,
                  gridData: FlGridData(show: true, horizontalInterval: 20),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF13233F),
                      getTooltipItems: (spots) => spots
                          .map((spot) => LineTooltipItem(
                                '${spot.y.toStringAsFixed(0)} BPM',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ))
                          .toList(),
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: const LinearGradient(colors: [AppTheme.electricBlue, AppTheme.cyan]),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: history.length <= 20,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.electricBlue.withOpacity(0.24),
                            AppTheme.cyan.withOpacity(0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Recent Scans', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...patient.ecgRecords.reversed.map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                borderColor: record.risk.color.withOpacity(0.35),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: record.risk.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(record.result, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(record.date)),
                  trailing: RiskBadge(risk: record.risk),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
