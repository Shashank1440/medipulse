import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:pinput/pinput.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  Timer? _timer;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      Fluttertoast.showToast(
          msg: 'Please enter complete OTP',
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }

    if (_phoneNumber == null) {
      Fluttertoast.showToast(
          msg: 'Phone number not found. Please try again.',
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance
          .verifyOTP(phoneNumber: _phoneNumber!, otpCode: _otpController.text);

      // Create session record
      await AuthService.instance
          .createSession(loginMethod: 'phone_otp', deviceInfo: {
        'platform': 'mobile',
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Navigate to main app
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.medicationList, (route) => false);
      }
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
            msg: error.toString().replaceAll('Exception: ', ''),
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_phoneNumber == null) return;

    try {
      await AuthService.instance.sendOTP(_phoneNumber!);
      _startResendTimer();

      Fluttertoast.showToast(
          msg: 'OTP sent successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white);
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Failed to resend OTP',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null) return '';
    return phone.length > 4
        ? phone.replaceRange(phone.length - 4, phone.length, '****')
        : phone;
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
        width: 12.w,
        height: 6.h,
        textStyle: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE0E0E0), width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white));

    final focusedPinTheme =
        defaultPinTheme.copyDecorationWith(border: Border.all(width: 2));

    final submittedPinTheme = defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration?.copyWith(
            color: Color(0xFFF8F9FA), border: Border.all(width: 1.5)));

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.pop(context))),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 4.h),

                      // Header
                      Text('Verify your phone',
                          style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      SizedBox(height: 1.h),
                      Text(
                          'We sent a code to ${_formatPhoneNumber(_phoneNumber)}',
                          style: GoogleFonts.inter(
                              fontSize: 16.sp, color: Colors.black54),
                          textAlign: TextAlign.center),
                      SizedBox(height: 4.h),

                      // OTP Input
                      Pinput(
                          controller: _otpController,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          pinputAutovalidateMode:
                              PinputAutovalidateMode.onSubmit,
                          showCursor: true,
                          onCompleted: (pin) => _verifyOTP()),

                      SizedBox(height: 4.h),

                      // Resend OTP
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Didn't receive code? ",
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp, color: Colors.black54)),
                            GestureDetector(
                                onTap: _canResend ? _resendOTP : null,
                                child: Text(
                                    _canResend
                                        ? 'Resend'
                                        : 'Resend in ${_resendTimer}s',
                                    style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600))),
                          ]),

                      const Spacer(),

                      // Verify Button
                      SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOTP,
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  disabledBackgroundColor: Colors.grey[300]),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)))
                                  : Text('Verify',
                                      style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600)))),
                      SizedBox(height: 3.h),
                    ]))));
  }
}
