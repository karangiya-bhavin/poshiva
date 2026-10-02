import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // HELPERS
  // ============================================================

  static String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String _normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedName = _normalizeName(fullName);
    final normalizedEmail = _normalizeEmail(email);

    return await _supabase.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {'full_name': normalizedName},
    );
  }

  // ============================================================
  // VERIFY SIGN-UP EMAIL OTP
  // ============================================================

  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedToken = token.trim();

    return await _supabase.auth.verifyOTP(
      email: normalizedEmail,
      token: normalizedToken,
      type: OtpType.email,
    );
  }

  // ============================================================
  // RESEND SIGN-UP VERIFICATION OTP
  // ============================================================

  static Future<ResendResponse> resendVerificationOtp({
    required String email,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    return await _supabase.auth.resend(
      type: OtpType.signup,
      email: normalizedEmail,
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    return await _supabase.auth.signInWithPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  static User? get currentUser {
    return _supabase.auth.currentUser;
  }

  // ============================================================
  // CURRENT SESSION
  // ============================================================

  static Session? get currentSession {
    return _supabase.auth.currentSession;
  }

  // ============================================================
  // AUTHENTICATION STATUS
  // ============================================================

  static bool get isLoggedIn {
    return _supabase.auth.currentSession != null;
  }

  // ============================================================
  // AUTH STATE CHANGES
  // ============================================================

  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
