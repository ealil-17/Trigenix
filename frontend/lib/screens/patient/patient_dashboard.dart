import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();

    if (provider.isLoading || provider.currentPatient == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final patient = provider.currentPatient!;
    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final metricSection = isTablet
        ? Row(
            children: [
              Expanded(
                child: MetricTile(
                  icon: Icons.favorite,
                  iconColor: AppTheme.danger,
                  label: 'Current Heart Rate',
                  value: '${patient.currentHeartRate} BPM',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MetricTile(
                  icon: Icons.analytics,
                  iconColor: AppTheme.electricBlue,
                  label: 'Total Scans',
                  value: '${patient.ecgRecords.length}',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MetricTile(
                  icon: Icons.timeline,
                  iconColor: AppTheme.warning,
                  label: 'Risk Entries',
                  value: '${patient.riskHistory.length}',
                ),
              ),
            ],
          )
        : Column(
            children: [
              MetricTile(
                icon: Icons.favorite,
                iconColor: AppTheme.danger,
                label: 'Current Heart Rate',
                value: '${patient.currentHeartRate} BPM',
              ),
              const SizedBox(height: 12),
              MetricTile(
                icon: Icons.analytics,
                iconColor: AppTheme.electricBlue,
                label: 'Total Scans',
                value: '${patient.ecgRecords.length}',
              ),
              const SizedBox(height: 12),
              MetricTile(
                icon: Icons.timeline,
                iconColor: AppTheme.warning,
                label: 'Risk Entries',
                value: '${patient.riskHistory.length}',
              ),
            ],
          );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            title: 'Hello, ${patient.name}',
            subtitle: 'Track your risk profile and stay ahead with actionable signals.',
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT RISK LEVEL',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Status updates adapt instantly after each ECG analysis.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ),
                      RiskBadge(risk: patient.currentRisk),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          patient.currentRisk.color.withOpacity(0.45),
                          patient.currentRisk.color,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          metricSection,
          const SizedBox(height: 16),
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.auto_graph, size: 34, color: AppTheme.electricBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Consistency matters: upload ECGs regularly to improve trend confidence and early warning reliability.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
