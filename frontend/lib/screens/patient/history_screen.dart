import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/patient.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<DataProvider>().currentPatient;
    if (patient == null) return const Center(child: Text('No data'));

    final history = patient.heartRateHistory;
    final spots = List.generate(history.length, (index) {
      return FlSpot(index.toDouble(), history[index].bpm.toDouble());
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Heart Rate Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.redAccent,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Recent Scans', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...patient.ecgRecords.reversed.map((record) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: record.risk.color,
                  radius: 10,
                ),
                title: Text(record.result, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(record.date)),
                trailing: Text(record.risk.displayName, style: TextStyle(color: record.risk.color, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
