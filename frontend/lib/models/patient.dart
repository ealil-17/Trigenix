import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelExtension on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orangeAccent;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return "LOW";
      case RiskLevel.medium:
        return "MEDIUM";
      case RiskLevel.high:
        return "HIGH";
    }
  }
}

class EcgRecord {
  final DateTime date;
  final String result;
  final RiskLevel risk;
  
  EcgRecord({required this.date, required this.result, required this.risk});
}

class HeartRateRecord {
  final DateTime time;
  final int bpm;
  
  HeartRateRecord({required this.time, required this.bpm});
}

class Patient {
  final String id;
  final String name;
  final int age;
  final List<HeartRateRecord> heartRateHistory;
  final List<EcgRecord> ecgRecords;
  final List<RiskLevel> riskHistory;
  
  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.heartRateHistory,
    required this.ecgRecords,
    required this.riskHistory,
  });

  RiskLevel get currentRisk => riskHistory.isNotEmpty ? riskHistory.last : RiskLevel.low;
  int get currentHeartRate => heartRateHistory.isNotEmpty ? heartRateHistory.last.bpm : 70;
}
