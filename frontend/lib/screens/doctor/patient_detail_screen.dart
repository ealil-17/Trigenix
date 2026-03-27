import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/patient.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';
import '../../theme/app_theme.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final chartHeight = isTablet ? 320.0 : 220.0;

    final spots = List.generate(patient.heartRateHistory.length, (index) {
      return FlSpot(index.toDouble(), patient.heartRateHistory[index].bpm.toDouble());
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Row(
                children: [
                  const CircleAvatar(radius: 36, backgroundColor: Colors.black12, child: Icon(Icons.person, size: 44)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        Text('ID: ${patient.id}  •  ${patient.age} years old', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                        const SizedBox(height: 8),
                        RiskBadge(risk: patient.currentRisk),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    icon: Icons.favorite,
                    iconColor: AppTheme.danger,
                    label: 'Current HR',
                    value: '${patient.currentHeartRate} BPM',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricTile(
                    icon: Icons.monitor_heart,
                    iconColor: AppTheme.electricBlue,
                    label: 'Total ECGs',
                    value: '${patient.ecgRecords.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionHeading(
              title: 'Heart Rate Trends',
              subtitle: 'Touch data points to inspect the BPM timeline.',
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: SizedBox(
                height: chartHeight,
                child: LineChart(
                  LineChartData(
                    minY: 40,
                    maxY: 180,
                    gridData: FlGridData(show: true, horizontalInterval: 20),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF13233F),
                        getTooltipItems: (items) => items
                            .map((item) => LineTooltipItem(
                                  '${item.y.toStringAsFixed(0)} BPM',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ))
                            .toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: const LinearGradient(colors: [AppTheme.electricBlue, AppTheme.cyan]),
                        barWidth: 3,
                        dotData: FlDotData(show: spots.length <= 24),
                        belowBarData: BarAreaData(show: true, color: AppTheme.electricBlue.withOpacity(0.18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('ECG Scan History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...patient.ecgRecords.reversed.map((record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  borderColor: record.risk.color.withOpacity(0.3),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.monitor_heart, color: record.risk.color, size: 30),
                    title: Text(record.result, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(record.date)),
                    trailing: RiskBadge(risk: record.risk),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
