import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/patient.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';
import 'patient_detail_screen.dart';

enum _SortBy { highRiskFirst, heartRateDesc, nameAsc }

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final TextEditingController _searchController = TextEditingController();
  _SortBy _sortBy = _SortBy.highRiskFirst;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _riskWeight(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.high:
        return 3;
      case RiskLevel.medium:
        return 2;
      case RiskLevel.low:
        return 1;
    }
  }

  List<Patient> _buildVisiblePatients(List<Patient> patients) {
    final query = _searchController.text.trim().toLowerCase();
    var filtered = patients.where((patient) {
      if (query.isEmpty) return true;
      return patient.name.toLowerCase().contains(query) || patient.id.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _SortBy.heartRateDesc:
          return b.currentHeartRate.compareTo(a.currentHeartRate);
        case _SortBy.nameAsc:
          return a.name.compareTo(b.name);
        case _SortBy.highRiskFirst:
          final riskCompare = _riskWeight(b.currentRisk).compareTo(_riskWeight(a.currentRisk));
          if (riskCompare != 0) return riskCompare;
          return b.currentHeartRate.compareTo(a.currentHeartRate);
      }
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<DataProvider>().patients;

    if (patients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);
    final visiblePatients = _buildVisiblePatients(patients);
    final highCount = patients.where((p) => p.currentRisk == RiskLevel.high).length;

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
      children: [
        const SectionHeading(
          title: 'Patient Monitoring',
          subtitle: 'Triage faster with prioritized risk and live trend context.',
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search by patient name or ID',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('High risk first'),
                      selected: _sortBy == _SortBy.highRiskFirst,
                      onSelected: (_) => setState(() => _sortBy = _SortBy.highRiskFirst),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Highest HR'),
                      selected: _sortBy == _SortBy.heartRateDesc,
                      onSelected: (_) => setState(() => _sortBy = _SortBy.heartRateDesc),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Name A-Z'),
                      selected: _sortBy == _SortBy.nameAsc,
                      onSelected: (_) => setState(() => _sortBy = _SortBy.nameAsc),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      icon: Icons.groups,
                      iconColor: AppTheme.electricBlue,
                      label: 'Total Patients',
                      value: '${patients.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricTile(
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppTheme.danger,
                      label: 'High Risk',
                      value: '$highCount',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...visiblePatients.map((patient) {
          final riskColor = patient.currentRisk.color;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              borderColor: riskColor.withOpacity(0.3),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.person, size: 30, color: Colors.black54),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
                title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text('ID: ${patient.id}  •  ${patient.age} yrs  •  HR ${patient.currentHeartRate} BPM'),
                ),
                trailing: RiskBadge(risk: patient.currentRisk),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
                  );
                },
              ),
            ),
          );
        }),
        if (visiblePatients.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: EmptyStatePanel(
              icon: Icons.search_off,
              title: 'No Matching Patients',
              message: 'Try a different name or patient ID to continue triage.',
            ),
          ),
      ],
    );
  }
}
