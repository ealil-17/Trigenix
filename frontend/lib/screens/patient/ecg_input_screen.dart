import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/data_provider.dart';
import '../../models/patient.dart';

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Upload ECG Data',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Upload a single-lead ECG CSV file (187 data points) to get an AI-powered arrhythmia risk assessment.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          InkWell(
            onTap: _isUploading ? null : _pickAndAnalyze,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading)
                    const CircularProgressIndicator()
                  else ...[
                    const Icon(Icons.upload_file, size: 64, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    const Text('Tap to select .csv file', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                  ]
                ],
              ),
            ),
          ),
          
          if (_error != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Text(_error!, style: TextStyle(color: Colors.red.shade900)),
            )
          ],

          if (_result != null) ...[
            const SizedBox(height: 32),
            const Text('Analysis Result', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(_result!['message'] ?? '', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(
                      'Probability: ${((_result!['arrhythmia_probability'] as double) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
