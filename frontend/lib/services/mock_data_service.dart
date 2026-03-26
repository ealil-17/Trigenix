import 'dart:math';
import '../models/patient.dart';

class MockDataService {
  static final _random = Random();
  static final List<String> _firstNames = ['John', 'Jane', 'Robert', 'Emily', 'Michael', 'Sarah', 'William', 'Jessica', 'David', 'Amanda', 'James', 'Ashley', 'Joseph', 'Megan', 'Charles', 'Elizabeth', 'Thomas', 'Lauren', 'Christopher', 'Nicole'];
  static final List<String> _lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'];

  static List<Patient> generatePatients({int count = 20}) {
    return List.generate(count, (index) {
      final name = '${_firstNames[_random.nextInt(_firstNames.length)]} ${_lastNames[_random.nextInt(_lastNames.length)]}';
      final age = 40 + _random.nextInt(45); // 40 to 85
      
      final historyCount = 5 + _random.nextInt(10);
      final heartRateHistory = <HeartRateRecord>[];
      final ecgRecords = <EcgRecord>[];
      final riskHistory = <RiskLevel>[];

      for (int i = 0; i < historyCount; i++) {
        final time = DateTime.now().subtract(Duration(days: historyCount - i));
        
        // Random Heart Rate 60-140
        final bpm = 60 + _random.nextInt(81);
        heartRateHistory.add(HeartRateRecord(time: time, bpm: bpm));

        // Random Risk level (weighted towards low)
        RiskLevel rLevel;
        final rv = _random.nextInt(10);
        if (rv < 6) {
          rLevel = RiskLevel.low;
        } else if (rv < 9) {
          rLevel = RiskLevel.medium;
        } else {
          rLevel = RiskLevel.high;
        }

        riskHistory.add(rLevel);
        
        String resultStr = rLevel == RiskLevel.low ? "Normal" : "Arrhythmia";
        ecgRecords.add(EcgRecord(date: time, result: resultStr, risk: rLevel));
      }

      return Patient(
        id: 'PT${1000 + index}',
        name: name,
        age: age,
        heartRateHistory: heartRateHistory,
        ecgRecords: ecgRecords,
        riskHistory: riskHistory,
      );
    });
  }
}
