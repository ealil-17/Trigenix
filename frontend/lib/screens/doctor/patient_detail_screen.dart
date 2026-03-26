import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/patient.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(patient.heartRateHistory.length, (index) {
      return FlSpot(index.toDouble(), patient.heartRateHistory[index].bpm.toDouble());
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 40, backgroundColor: Colors.black12, child: Icon(Icons.person, size: 50)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('ID: ${patient.id}  •  ${patient.age} years old', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: patient.currentRisk.color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '${patient.currentRisk.displayName} RISK',
                              style: TextStyle(color: patient.currentRisk.color, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Heart Rate Trend
            const Text('Heart Rate Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('ECG Scan History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...patient.ecgRecords.reversed.map((record) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: record.risk == RiskLevel.high ? Colors.redAccent.shade100 : Colors.transparent, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(Icons.monitor_heart, color: record.risk.color, size: 32),
                  title: Text(record.result, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(record.date)),
                  trailing: Text(record.risk.displayName, style: TextStyle(color: record.risk.color, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
