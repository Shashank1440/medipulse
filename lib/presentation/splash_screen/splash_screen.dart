import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppTheme.lightTheme.primaryColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Step 1: Initialize database
      await _updateProgress(0.2, 'Setting up secure database...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Check authentication
      await _updateProgress(0.4, 'Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Step 3: Load user profiles
      await _updateProgress(0.6, 'Loading medication profiles...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Step 4: Verify permissions
      await _updateProgress(0.8, 'Verifying permissions...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Step 5: Prepare cache
      await _updateProgress(1.0, 'Finalizing setup...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isInitializing = false;
      });

      // Navigate based on app state
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToNextScreen();
    } catch (e) {
      setState(() {
        _initializationStatus = 'Setup failed. Retrying...';
      });
      await Future.delayed(const Duration(seconds: 2));
      _initializeApp();
    }
  }

  Future<void> _updateProgress(double progress, String status) async {
    setState(() {
      _progress = progress;
      _initializationStatus = status;
    });
  }

  void _navigateToNextScreen() {
    // Simulate authentication and profile check
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool hasProfiles = _checkUserProfiles();
    final bool hasMedications = _checkMedicationData();

    if (!isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/profile-selection-screen');
    } else if (hasProfiles && hasMedications) {
      Navigator.pushReplacementNamed(context, '/medication-list-screen');
    } else if (hasProfiles) {
      Navigator.pushReplacementNamed(context, '/add-medication-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/profile-selection-screen');
    }
  }

  bool _checkAuthenticationStatus() {
    // Mock authentication check - in real app would check secure storage
    return DateTime.now().millisecondsSinceEpoch % 2 == 0;
  }

  bool _checkUserProfiles() {
    // Mock profile check - in real app would check database
    return DateTime.now().millisecondsSinceEpoch % 3 != 0;
  }

  bool _checkMedicationData() {
    // Mock medication data check - in real app would check database
    return DateTime.now().millisecondsSinceEpoch % 4 != 0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.6),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo Section
                _buildLogoSection(),

                SizedBox(height: 8.h),

                // App Name
                _buildAppNameSection(),

                SizedBox(height: 4.h),

                // Tagline
                _buildTaglineSection(),

                const Spacer(flex: 2),

                // Loading Section
                _buildLoadingSection(),

                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'medical_services',
                color: AppTheme.lightTheme.primaryColor,
                size: 12.w,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppNameSection() {
    return Text(
      'MediPulse',
      style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.surface,
        fontWeight: FontWeight.w700,
        fontSize: 20.sp,
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTaglineSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        'Your trusted medication companion',
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Progress Indicator
        Container(
          width: 60.w,
          height: 0.8.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.surface,
              ),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Status Text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _initializationStatus,
            key: ValueKey(_initializationStatus),
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 2.h),

        // Loading Dots Animation
        _isInitializing ? _buildLoadingDots() : Container(),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.3;
            final animationValue = (_pulseController.value + delay) % 1.0;
            final opacity = (animationValue < 0.5)
                ? (animationValue * 2)
                : (2 - animationValue * 2);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface.withValues(
                  alpha: opacity.clamp(0.3, 1.0),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
