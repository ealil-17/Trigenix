import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import 'patient_detail_screen.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highRiskPatients = context.watch<DataProvider>().highRiskPatients;

    return Scaffold(
      body: highRiskPatients.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('All Clear', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('No patients are currently at HIGH risk.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: highRiskPatients.length,
              itemBuilder: (context, index) {
                final patient = highRiskPatients[index];

                return Card(
                  color: Colors.red.shade50,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red.shade200, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
                    title: Text('CRITICAL: ${patient.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                    subtitle: Text('ID: ${patient.id} requires immediate attention.\nLast HR: ${patient.currentHeartRate} BPM'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
