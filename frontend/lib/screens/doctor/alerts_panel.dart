import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';
import 'patient_detail_screen.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highRiskPatients = context.watch<DataProvider>().highRiskPatients;
    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);

    if (highRiskPatients.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
        child: const Center(
          child: EmptyStatePanel(
            icon: Icons.check_circle_outline,
            title: 'All Clear',
            message: 'No patients are currently at high risk. Monitoring remains active.',
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
      children: [
        SectionHeading(
          title: 'Critical Alerts',
          subtitle: '${highRiskPatients.length} patient(s) require immediate review.',
        ),
        const SizedBox(height: 14),
        ...highRiskPatients.map((patient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: AppTheme.danger.withOpacity(0.55),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppTheme.danger.withOpacity(0.16),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CRITICAL: ${patient.name}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.danger)),
                        const SizedBox(height: 2),
                        Text('ID ${patient.id}  •  HR ${patient.currentHeartRate} BPM', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Open patient',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
                      );
                    },
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            )
          );
        }),
      ],
    );
  }
}
