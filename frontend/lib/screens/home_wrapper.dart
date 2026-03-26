import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'patient/patient_main_screen.dart';
import 'doctor/doctor_main_screen.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    
    if (role == AppRole.doctor) {
      return const DoctorMainScreen();
    } else {
      return const PatientMainScreen();
    }
  }
}
