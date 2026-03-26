import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/mock_data_service.dart';

class DataProvider with ChangeNotifier {
  List<Patient> _patients = [];
  bool _isLoading = false;
  
  // For the patient view, we mock a "current" patient
  Patient? _currentPatient;

  List<Patient> get patients => _patients;
  Patient? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;

  DataProvider() {
    loadMockData();
  }

  void loadMockData() {
    _isLoading = true;
    notifyListeners();
    
    // Generate synthetic data
    _patients = MockDataService.generatePatients(count: 20);
    _currentPatient = _patients.first; // Mock logged-in patient
    
    _isLoading = false;
    notifyListeners();
  }
  
  void addEcgRecordToCurrentTarget(EcgRecord record) {
    if (_currentPatient != null) {
      _currentPatient!.ecgRecords.add(record);
      _currentPatient!.riskHistory.add(record.risk);
      notifyListeners();
    }
  }
  
  List<Patient> get highRiskPatients {
    return _patients.where((p) => p.currentRisk == RiskLevel.high).toList();
  }
}
