import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poshiva/screens/auth/account_created.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, this.email = 'bhavin@gmail.com'});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  int secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

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

  // --------------------------------------------------
  // Start / Restart Timer
  // --------------------------------------------------

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      secondsRemaining = 45;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // --------------------------------------------------
  // Timer formatting
  // --------------------------------------------------

  String _formatTime(int value) {
    final minutes = value ~/ 60;
    final seconds = value % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // --------------------------------------------------
  // OTP input handler
  // --------------------------------------------------

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

      final nextValue = digitsOnly.isEmpty ? '' : digitsOnly.substring(0, 1);

      otpControllers[index].text = nextValue;

      otpControllers[index].selection = const TextSelection.collapsed(
        offset: 1,
      );

      if (nextValue.isNotEmpty && index < otpFocusNodes.length - 1) {
        otpFocusNodes[index + 1].requestFocus();
      }

      return;
    }

    if (value.length == 1 && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  // --------------------------------------------------
  // Check OTP
  // --------------------------------------------------

  bool _isOtpComplete() {
    return otpControllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
  }

  // --------------------------------------------------
  // Verify OTP
  // --------------------------------------------------

  void _verifyOtp() {
    if (!_isOtpComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ----------------------------------------------
    // OTP is entered.
    //
    // For now we don't connect a real backend.
    // We directly continue to the Account Created
    // screen.
    // ----------------------------------------------

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AccountCreatedScreen()),
    );
  }

  // --------------------------------------------------
  // OTP Box
  // --------------------------------------------------

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 42,
      height: 52,
      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],
        keyboardType: TextInputType.number,
        cursorColor: const Color(0xFF078D3B),
        textInputAction: index == 5
            ? TextInputAction.done
            : TextInputAction.next,
        textAlign: TextAlign.center,
        maxLength: 1,
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

  // --------------------------------------------------
  // Build
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Keep background and grass fixed when keyboard opens.
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // ==================================================
          // Fixed Background
          // ==================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==================================================
          // Main Content
          // ==================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Column(
                children: [
                  const SizedBox(height: 27),

                  // --------------------------------------------------
                  // Verification Illustration
                  // --------------------------------------------------
                  Image.asset(
                    'assets/images/email_verification.png',
                    width: 260,
                    height: 185,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 15),

                  // --------------------------------------------------
                  // Title
                  // --------------------------------------------------
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

                  // --------------------------------------------------
                  // Verification Message
                  // --------------------------------------------------
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

                  // --------------------------------------------------
                  // Email
                  // --------------------------------------------------
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

                  // --------------------------------------------------
                  // Instruction
                  // --------------------------------------------------
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

                  // --------------------------------------------------
                  // OTP Boxes
                  // --------------------------------------------------
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

                  // --------------------------------------------------
                  // Didn't receive code
                  // --------------------------------------------------
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

                  // --------------------------------------------------
                  // Resend Code
                  // --------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (secondsRemaining == 0) {
                            _startTimer();
                          }
                        },
                        child: Text(
                          'Resend Code',
                          style: TextStyle(
                            color: secondsRemaining == 0
                                ? const Color(0xFF078D3B)
                                : const Color(0xFF8CA096),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            decoration: secondsRemaining == 0
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

                  // --------------------------------------------------
                  // Verify Button
                  // --------------------------------------------------
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

                          // IMPORTANT:
                          // Verify → Account Created
                          onTap: _verifyOtp,

                          child: const Center(
                            child: Text(
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

                  // --------------------------------------------------
                  // Change Email
                  // --------------------------------------------------
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
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
                ],
              ),
            ),
          ),

          // ==================================================
          // Fixed Bottom Grass
          // ==================================================
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
