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

  static String _normalizeOtp(String token) {
    return token.replaceAll(RegExp(r'\D'), '').trim();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final String normalizedName = _normalizeName(fullName);

    final String normalizedEmail = _normalizeEmail(email);

    // ----------------------------------------------------------
    // NAME VALIDATION
    // ----------------------------------------------------------

    if (normalizedName.isEmpty) {
      throw const AuthException('Full name is required.');
    }

    if (normalizedName.length < 2) {
      throw const AuthException('Full name must be at least 2 characters.');
    }

    if (normalizedName.length > 60) {
      throw const AuthException('Full name must be less than 60 characters.');
    }

    // ----------------------------------------------------------
    // EMAIL VALIDATION
    // ----------------------------------------------------------

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email address is required.');
    }

    // Correct Dart raw-string email regex.
    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw const AuthException('Please enter a valid email address.');
    }

    // ----------------------------------------------------------
    // PASSWORD VALIDATION
    // ----------------------------------------------------------

    if (password.isEmpty) {
      throw const AuthException('Password is required.');
    }

    if (password.length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      throw const AuthException(
        'Password must contain at least one uppercase letter.',
      );
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      throw const AuthException(
        'Password must contain at least one lowercase letter.',
      );
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      throw const AuthException('Password must contain at least one number.');
    }

    // ============================================================
    // SUPABASE SIGN UP
    // ============================================================

    final AuthResponse response = await _supabase.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: <String, dynamic>{'full_name': normalizedName},
    );

    // ============================================================
    // IMPORTANT
    //
    // When Supabase "Confirm Email" is enabled:
    //
    // response.user    -> user is returned
    // response.session -> can be null
    //
    // Therefore registration success MUST be determined using
    // response.user, NOT response.session.
    // ============================================================

    if (response.user == null) {
      throw const AuthException(
        'We could not create your account. Please try again.',
      );
    }

    return response;
  }

  // ============================================================
  // VERIFY EMAIL OTP
  // ============================================================

  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);

    final String normalizedToken = _normalizeOtp(token);

    // ----------------------------------------------------------
    // EMAIL VALIDATION
    // ----------------------------------------------------------

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email address is required.');
    }

    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw const AuthException('Please enter a valid email address.');
    }

    // ----------------------------------------------------------
    // OTP VALIDATION
    // ----------------------------------------------------------

    if (normalizedToken.isEmpty) {
      throw const AuthException('Please enter the verification code.');
    }

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedToken)) {
      throw const AuthException(
        'Please enter the complete 6-digit verification code.',
      );
    }

    // ============================================================
    // SUPABASE EMAIL OTP VERIFICATION
    //
    // Current Supabase Flutter API:
    //
    // OtpType.email
    //
    // Do NOT use OtpType.signup for the email verification flow.
    // ============================================================

    final AuthResponse response = await _supabase.auth.verifyOTP(
      email: normalizedEmail,
      token: normalizedToken,
      type: OtpType.email,
    );

    // ----------------------------------------------------------
    // VERIFICATION SUCCESS CHECK
    // ----------------------------------------------------------

    if (response.user == null) {
      throw const AuthException(
        'Email verification could not be completed. '
        'Please try again.',
      );
    }

    return response;
  }

  // ============================================================
  // RESEND EMAIL VERIFICATION OTP
  // ============================================================

  static Future<ResendResponse> resendVerificationOtp({
    required String email,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);

    // ----------------------------------------------------------
    // EMAIL VALIDATION
    // ----------------------------------------------------------

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email address is required.');
    }

    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw const AuthException('Please enter a valid email address.');
    }

    // ============================================================
    // RESEND SIGN-UP CONFIRMATION EMAIL
    //
    // Current Supabase API uses:
    //
    // OtpType.email
    // ============================================================

    return await _supabase.auth.resend(
      type: OtpType.email,
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
    final String normalizedEmail = _normalizeEmail(email);

    // ----------------------------------------------------------
    // EMAIL VALIDATION
    // ----------------------------------------------------------

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email address is required.');
    }

    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw const AuthException('Please enter a valid email address.');
    }

    // ----------------------------------------------------------
    // PASSWORD VALIDATION
    // ----------------------------------------------------------

    if (password.isEmpty) {
      throw const AuthException('Password is required.');
    }

    // ============================================================
    // SUPABASE LOGIN
    // ============================================================

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
  // EMAIL CONFIRMATION STATUS
  // ============================================================

  static bool get isEmailConfirmed {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    return user.emailConfirmedAt != null;
  }

  // ============================================================
  // AUTH STATE CHANGES
  // ============================================================

  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
