import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:country_picker/country_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Country _selectedCountry = Country(
      phoneCode: '1',
      countryCode: 'US',
      e164Sc: 1,
      geographic: true,
      level: 1,
      name: 'United States',
      example: '2012345678',
      displayName: 'United States (US) [+1]',
      displayNameNoCountryCode: 'United States (US)',
      e164Key: '1-US-0');

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phoneNumber =
          '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}';

      await AuthService.instance.sendOTP(phoneNumber);

      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.otpVerification,
            arguments: phoneNumber);
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

  void _selectCountry() {
    showCountryPicker(
        context: context,
        countryListTheme: CountryListThemeData(
            flagSize: 25,
            backgroundColor: Colors.white,
            textStyle: GoogleFonts.inter(fontSize: 16),
            bottomSheetHeight: 60.h,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
            inputDecoration: InputDecoration(
                labelText: 'Search Country',
                hintText: 'Start typing to search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFFE0E0E0))))),
        onSelect: (Country country) {
          setState(() {
            _selectedCountry = country;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),

                          // Header
                          Text('Enter your phone number',
                              style: GoogleFonts.inter(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          SizedBox(height: 1.h),
                          Text('We\'ll send you a verification code',
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp, color: Colors.black54)),
                          SizedBox(height: 4.h),

                          // Phone Input
                          Text('Phone Number',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          SizedBox(height: 1.h),

                          Row(children: [
                            // Country Code Selector
                            GestureDetector(
                                onTap: _selectCountry,
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 1.5.h),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFFE0E0E0)),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              '${_selectedCountry.flagEmoji} +${_selectedCountry.phoneCode}',
                                              style: GoogleFonts.inter(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(width: 1.w),
                                          Icon(Icons.keyboard_arrow_down,
                                              size: 20),
                                        ]))),
                            SizedBox(width: 3.w),

                            // Phone Number Input
                            Expanded(
                                child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: GoogleFonts.inter(fontSize: 16.sp),
                                    decoration: InputDecoration(
                                        hintText: 'Enter phone number',
                                        hintStyle: GoogleFonts.inter(
                                            color: Colors.black38,
                                            fontSize: 16.sp),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Color(0xFFE0E0E0))),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Color(0xFFE0E0E0))),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(width: 2)),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 4.w, vertical: 1.5.h)),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.trim().length < 6) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    })),
                          ]),

                          SizedBox(height: 3.h),

                          // Privacy Notice
                          Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Color(0xFFE9ECEF))),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline, size: 20),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                        child: Text(
                                            'By continuing, you agree to receive SMS messages. Message and data rates may apply.',
                                            style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                color: Colors.black54,
                                                height: 1.4))),
                                  ])),

                          const Spacer(),

                          // Continue Button
                          SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendOTP,
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      disabledBackgroundColor:
                                          Colors.grey[300]),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white)))
                                      : Text('Continue',
                                          style: GoogleFonts.inter(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600)))),
                          SizedBox(height: 3.h),
                        ])))));
  }
}
