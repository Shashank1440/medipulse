import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),

                      // App Logo
                      CustomImageWidget(
                          imageUrl: 'assets/images/logo.png',
                          height: 12.h, width: 12.h, fit: BoxFit.contain),
                      SizedBox(height: 3.h),

                      // App Title
                      Text('MediPulse',
                          style: GoogleFonts.inter(
                              fontSize: 32.sp, fontWeight: FontWeight.w800)),
                      SizedBox(height: 1.h),

                      // Subtitle
                      Text('Your Personal Medication Manager',
                          style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 6.h),

                      // Features List
                      _buildFeatureItem(
                          icon: Icons.medication_outlined,
                          title: 'Medication Tracking',
                          subtitle: 'Never miss a dose with smart reminders'),
                      SizedBox(height: 3.h),

                      _buildFeatureItem(
                          icon: Icons.analytics_outlined,
                          title: 'Health Analytics',
                          subtitle:
                              'Track your medication adherence and progress'),
                      SizedBox(height: 3.h),

                      _buildFeatureItem(
                          icon: Icons.family_restroom_outlined,
                          title: 'Family Profiles',
                          subtitle: 'Manage medications for your loved ones'),

                      const Spacer(),

                      // Continue with Phone Button
                      SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.phoneLogin),
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone_android, size: 20),
                                    SizedBox(width: 2.w),
                                    Text('Continue with Phone',
                                        style: GoogleFonts.inter(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600)),
                                  ]))),
                      SizedBox(height: 2.h),

                      // Skip for Now (Preview Mode)
                      TextButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.medicationList,
                              (route) => false),
                          child: Text('Continue as Guest',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54))),
                      SizedBox(height: 3.h),
                    ]))));
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 24)),
      SizedBox(width: 4.w),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        SizedBox(height: 0.5.h),
        Text(subtitle,
            style: GoogleFonts.inter(
                fontSize: 14.sp, color: Colors.black54, height: 1.4)),
      ])),
    ]);
  }
}