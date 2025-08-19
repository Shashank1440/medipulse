import 'package:flutter/material.dart';
import '../presentation/medication_list_screen/medication_list_screen.dart';
import '../presentation/reports_screen/reports_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/add_medication_screen/add_medication_screen.dart';
import '../presentation/medication_detail_screen/medication_detail_screen.dart';
import '../presentation/profile_selection_screen/profile_selection_screen.dart';
import '../presentation/auth_screens/welcome_screen.dart';
import '../presentation/auth_screens/phone_login_screen.dart';
import '../presentation/auth_screens/otp_verification_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String welcome = '/welcome';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String medicationList = '/medication-list-screen';
  static const String reports = '/reports-screen';
  static const String splash = '/splash-screen';
  static const String addMedication = '/add-medication-screen';
  static const String medicationDetail = '/medication-detail-screen';
  static const String profileSelection = '/profile-selection-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const WelcomeScreen(),
    welcome: (context) => const WelcomeScreen(),
    phoneLogin: (context) => const PhoneLoginScreen(),
    otpVerification: (context) => const OtpVerificationScreen(),
    medicationList: (context) => const MedicationListScreen(),
    reports: (context) => const ReportsScreen(),
    splash: (context) => const SplashScreen(),
    addMedication: (context) => const AddMedicationScreen(),
    medicationDetail: (context) => const MedicationDetailScreen(),
    profileSelection: (context) => const ProfileSelectionScreen(),
    // TODO: Add your other routes here
  };
}
