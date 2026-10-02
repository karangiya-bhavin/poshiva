import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poshiva/screens/auth/account_created.dart';
import 'package:poshiva/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // ============================================================
  // OTP
  // ============================================================

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  // ============================================================
  // STATE
  // ============================================================

  int secondsRemaining = 300;

  Timer? _timer;

  bool isVerifying = false;
  bool isResending = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in otpFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // START TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    if (!mounted) return;

    setState(() {
      secondsRemaining = 300;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // ============================================================
  // FORMAT TIMER
  // ============================================================

  String _formatTime(int value) {
    final minutes = value ~/ 60;
    final seconds = value % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // OTP CHANGE
  // ============================================================

  void _onOtpChanged(String value, int index) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // ------------------------------------------------------------
    // EMPTY / BACKSPACE
    // ------------------------------------------------------------

    if (digitsOnly.isEmpty) {
      otpControllers[index].clear();

      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }

      setState(() {});

      return;
    }

    // ------------------------------------------------------------
    // LIMIT TO AVAILABLE BOXES
    // ------------------------------------------------------------

    final available = 6 - index;

    final digits = digitsOnly.substring(
      0,
      digitsOnly.length > available ? available : digitsOnly.length,
    );

    // ------------------------------------------------------------
    // FILL OTP BOXES
    // ------------------------------------------------------------

    for (int i = 0; i < digits.length; i++) {
      final targetIndex = index + i;

      otpControllers[targetIndex].text = digits[i];

      otpControllers[targetIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
    }

    // ------------------------------------------------------------
    // MOVE FOCUS
    // ------------------------------------------------------------

    final lastIndex = index + digits.length - 1;

    if (lastIndex < 5) {
      otpFocusNodes[lastIndex + 1].requestFocus();
    } else {
      otpFocusNodes[5].unfocus();
    }

    setState(() {});
  }

  // ============================================================
  // GET OTP
  // ============================================================

  String _getOtp() {
    return otpControllers.map((controller) => controller.text.trim()).join();
  }

  // ============================================================
  // OTP COMPLETE
  // ============================================================

  bool _isOtpComplete() {
    return _getOtp().length == 6;
  }

  // ============================================================
  // CLEAR OTP
  // ============================================================

  void _clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }

    if (mounted) {
      otpFocusNodes[0].requestFocus();

      setState(() {});
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (isVerifying) {
      return;
    }

    // ------------------------------------------------------------
    // CHECK OTP
    // ------------------------------------------------------------

    if (!_isOtpComplete()) {
      _showMessage('Please enter the complete 6-digit code.', isError: true);

      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      final otp = _getOtp();

      // ----------------------------------------------------------
      // SUPABASE OTP VERIFICATION
      // ----------------------------------------------------------

      final response = await AuthService.verifyEmailOtp(
        email: widget.email,
        token: otp,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountCreatedScreen()),
        );
      } else {
        _showMessage(
          'Email verification failed. Please try again.',
          isError: true,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(_getAuthErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _resendOtp() async {
    if (secondsRemaining > 0 || isResending || isVerifying) {
      return;
    }

    setState(() {
      isResending = true;
    });

    try {
      await AuthService.resendVerificationOtp(email: widget.email);

      if (!mounted) return;

      _clearOtp();

      _startTimer();

      _showMessage(
        'A new verification code has been sent to your email.',
        isError: false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(_getAuthErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Unable to resend the code. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  // ============================================================
  // AUTH ERROR MESSAGE
  // ============================================================

  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('expired')) {
      return 'This verification code has expired. Please request a new code.';
    }

    if (message.contains('invalid') || message.contains('token')) {
      return 'Invalid verification code. Please check the code and try again.';
    }

    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Too many attempts. Please wait and try again.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'Verification failed. Please check the code and try again.';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFFD32F2F) : null,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ============================================================
  // OTP BOX
  // ============================================================

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 42,
      height: 52,
      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],

        keyboardType: TextInputType.number,

        textInputAction: index == 5
            ? TextInputAction.done
            : TextInputAction.next,

        textAlign: TextAlign.center,

        maxLength: 6,

        cursorColor: const Color(0xFF078D3B),

        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

        style: const TextStyle(
          color: Color(0xFF102126),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),

        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,

          contentPadding: EdgeInsets.zero,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE7EEF0)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE7EEF0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF078D3B), width: 1.5),
          ),
        ),

        onChanged: (value) {
          _onOtpChanged(value, index);
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Column(
                  children: [
                    const SizedBox(height: 27),

                    // ==================================================
                    // ILLUSTRATION
                    // ==================================================
                    Image.asset(
                      'assets/images/email_verification.png',
                      width: 260,
                      height: 185,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // TITLE
                    // ==================================================
                    const Text(
                      'Verify Your Email',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF102B26),
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // MESSAGE
                    // ==================================================
                    const Text(
                      'We’ve sent a 6-digit verification code to',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF687980),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // EMAIL
                    // ==================================================
                    Text(
                      widget.email,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Color(0xFF102B26),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // INSTRUCTION
                    // ==================================================
                    const Text(
                      'Enter the code below to verify your account.',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF687980),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 43),

                    // ==================================================
                    // OTP BOXES
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: List.generate(6, (index) {
                        return Padding(
                          padding: EdgeInsets.only(right: index == 5 ? 0 : 10),
                          child: _buildOtpBox(index),
                        );
                      }),
                    ),

                    const SizedBox(height: 43),

                    // ==================================================
                    // DIDN'T RECEIVE
                    // ==================================================
                    const Text(
                      'Didn’t receive the code?',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF687980),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // RESEND
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        GestureDetector(
                          onTap:
                              (secondsRemaining == 0 &&
                                  !isResending &&
                                  !isVerifying)
                              ? _resendOtp
                              : null,

                          child: Text(
                            isResending ? 'Sending...' : 'Resend Code',

                            style: TextStyle(
                              color: secondsRemaining == 0 && !isResending
                                  ? const Color(0xFF078D3B)
                                  : const Color(0xFF8CA096),

                              fontSize: 17,

                              fontWeight: FontWeight.w600,

                              decoration: secondsRemaining == 0 && !isResending
                                  ? TextDecoration.underline
                                  : TextDecoration.none,

                              decorationColor: const Color(0xFF078D3B),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '(${_formatTime(secondsRemaining)})',

                          style: const TextStyle(
                            color: Color(0xFF687980),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // ==================================================
                    // VERIFY BUTTON
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,

                            end: Alignment.centerRight,

                            colors: [Color(0xFF078D3B), Color(0xFF13A847)],
                          ),

                          borderRadius: BorderRadius.circular(28),

                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF078D3B,
                              ).withValues(alpha: 0.18),

                              blurRadius: 5,

                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Material(
                          color: Colors.transparent,

                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),

                            onTap: isVerifying ? null : _verifyOtp,

                            child: Center(
                              child: isVerifying
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,

                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Verify',

                                      style: TextStyle(
                                        color: Colors.white,

                                        fontSize: 17,

                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // CHANGE EMAIL
                    // ==================================================
                    GestureDetector(
                      onTap: isVerifying
                          ? null
                          : () {
                              Navigator.pop(context);
                            },

                      child: const Text(
                        'Change Email',

                        style: TextStyle(
                          color: Color(0xFF078D3B),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // GRASS
          // ======================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,

            child: IgnorePointer(
              child: Image.asset(
                'assets/images/login_grass.png',

                width: MediaQuery.sizeOf(context).width,

                fit: BoxFit.fitWidth,

                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
