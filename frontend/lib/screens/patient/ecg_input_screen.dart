import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/data_provider.dart';
import '../../models/patient.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';

class EcgInputScreen extends StatefulWidget {
  const EcgInputScreen({Key? key}) : super(key: key);

  @override
  State<EcgInputScreen> createState() => _EcgInputScreenState();
}

class _EcgInputScreenState extends State<EcgInputScreen> {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _pickAndAnalyze() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isUploading = true;
          _error = null;
          _result = null;
        });

        final fileName = result.files.single.name;
        final fileBytes = result.files.single.bytes!;

        final apiResponse = await _apiService.uploadEcgFile(fileName, fileBytes);
        
        setState(() {
          _result = apiResponse;
          _isUploading = false;
        });

        // Add this to our mock data history
        if (mounted && _result != null) {
          final riskStr = _result!['risk_level'] as String;
          RiskLevel rLevel = RiskLevel.low;
          if (riskStr == "Medium") rLevel = RiskLevel.medium;
          if (riskStr == "High") rLevel = RiskLevel.high;

          context.read<DataProvider>().addEcgRecordToCurrentTarget(
            EcgRecord(
              date: DateTime.now(), 
              result: rLevel == RiskLevel.low ? "Normal" : "Arrhythmia Detected", 
              risk: rLevel
            ),
          );
        }
      }
    } on ApiServiceException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unexpected error while uploading ECG data. Please try again.';
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);
    final viewportHeight = MediaQuery.of(context).size.height;
    final uploadHeight = (viewportHeight * 0.26).clamp(180.0, 300.0);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            title: 'Upload ECG Data',
            subtitle: 'Drop or select a single-lead CSV file (187 points) for an instant AI risk score.',
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: _isUploading ? null : _pickAndAnalyze,
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              height: uploadHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isUploading ? AppTheme.cyan : AppTheme.electricBlue.withOpacity(0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.electricBlue.withOpacity(0.08),
                    AppTheme.cyan.withOpacity(0.08),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading)
                    const CircularProgressIndicator()
                  else ...[
                    const Icon(Icons.cloud_upload_rounded, size: 66, color: AppTheme.electricBlue),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to select .csv file',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.electricBlue,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Interactive analysis starts instantly after upload',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ]
                ],
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 18),
            GlassCard(
              borderColor: AppTheme.danger.withOpacity(0.5),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.danger),
                    ),
                  ),
                ],
              ),
            )
          ],

          if (_result != null) ...[
            const SizedBox(height: 22),
            Text('Analysis Result', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final riskLevel = _result!['risk_level'] as String? ?? 'Low';
              Color riskColor;
              IconData riskIcon;
              if (riskLevel == 'High') {
                riskColor = Colors.red;
                riskIcon = Icons.warning_rounded;
              } else if (riskLevel == 'Medium') {
                riskColor = Colors.orange;
                riskIcon = Icons.info_rounded;
              } else {
                riskColor = Colors.green;
                riskIcon = Icons.check_circle_rounded;
              }
              return GlassCard(
                borderColor: riskColor.withOpacity(0.5),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(riskIcon, color: riskColor, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$riskLevel Risk Detected',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: riskColor, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'The uploaded ECG pattern indicates a $riskLevel probability of arrhythmia. Continue monitoring and compare upcoming uploads for trend stability.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            })
          ]
        ],
      ),
    );
  }
}
