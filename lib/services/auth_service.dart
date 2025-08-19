import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Send OTP to phone number
  Future<AuthResponse> sendOTP(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
      );
      // Return a dummy AuthResponse since signInWithOtp returns void
      return AuthResponse();
    } catch (error) {
      throw Exception('Failed to send OTP: $error');
    }
  }

  // Verify OTP and sign in
  Future<AuthResponse> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: otpCode,
        type: OtpType.sms,
      );
      return response;
    } catch (error) {
      throw Exception('Failed to verify OTP: $error');
    }
  }

  // Sign up with email and password (backup method)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      return response;
    } catch (error) {
      throw Exception('Failed to sign up: $error');
    }
  }

  // Sign in with email and password (backup method)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Failed to sign in: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Failed to sign out: $error');
    }
  }

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (!isAuthenticated) throw Exception('User not authenticated');

      await _client.from('user_profiles').update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Create user session record
  Future<void> createSession({
    required String loginMethod,
    Map<String, dynamic>? deviceInfo,
    String? ipAddress,
  }) async {
    try {
      if (!isAuthenticated) return;

      await _client.from('user_sessions').insert({
        'user_id': currentUser!.id,
        'login_method': loginMethod,
        'device_info': deviceInfo,
        'ip_address': ipAddress,
        'login_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Non-critical operation, log but don't throw
      print('Failed to create session record: $error');
    }
  }

  // Get user sessions
  Future<List<dynamic>> getUserSessions() async {
    try {
      if (!isAuthenticated) return [];

      final response = await _client
          .from('user_sessions')
          .select()
          .eq('user_id', currentUser!.id)
          .order('login_at', ascending: false)
          .limit(10);

      return response;
    } catch (error) {
      throw Exception('Failed to get sessions: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Failed to reset password: $error');
    }
  }
}