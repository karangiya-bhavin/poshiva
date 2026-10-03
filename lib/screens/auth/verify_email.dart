import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:poshiva/screens/auth/account_created.dart';
import 'package:poshiva/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int otpLength = 6;
  static const int resendCooldownSeconds = 120;

  static const Color primaryGreen = Color(0xFF078D3B);

  static const Color darkText = Color(0xFF102B26);
  static const Color secondaryText = Color(0xFF687980);
  static const Color mutedText = Color(0xFF8CA096);

  static const Color borderColor = Color(0xFFD5E0DC);
  static const Color softGreen = Color(0xFFEFFAF3);
  static const Color softGreenBorder = Color(0xFFD8EFDF);

  static const Color errorRed = Color(0xFFD32F2F);
  static const Color errorBackground = Color(0xFFFFF5F5);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final List<TextEditingController> _otpControllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  Timer? _timer;

  int _secondsRemaining = resendCooldownSeconds;

  bool _isVerifying = false;
  bool _isResending = false;

  bool _hasOtpError = false;
  String? _otpErrorMessage;

  bool _autoVerifyScheduled = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final node in _otpFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startResendTimer() {
    _timer?.cancel();

    if (!mounted) return;

    setState(() {
      _secondsRemaining = resendCooldownSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _secondsRemaining = 0;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // OTP HELPERS
  // ============================================================

  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  String _extractDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  bool _isOtpComplete() {
    final otp = _getOtp();

    return otp.length == otpLength && RegExp(r'^\d{6}$').hasMatch(otp);
  }

  void _clearOtpError() {
    if (!mounted || !_hasOtpError) return;

    setState(() {
      _hasOtpError = false;
      _otpErrorMessage = null;
    });
  }

  void _setOtpError(String message) {
    if (!mounted) return;

    setState(() {
      _hasOtpError = true;
      _otpErrorMessage = message;
    });
  }

  // ============================================================
  // CLEAR OTP
  // ============================================================

  void _clearOtp({bool requestFocus = true}) {
    for (final controller in _otpControllers) {
      controller.clear();
    }

    _autoVerifyScheduled = false;

    if (!mounted) return;

    setState(() {
      _hasOtpError = false;
      _otpErrorMessage = null;
    });

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _otpFocusNodes.first.requestFocus();
        }
      });
    }
  }

  // ============================================================
  // OTP INPUT
  // ============================================================

  void _onOtpChanged(String value, int index) {
    if (!mounted || _isVerifying || _isResending) return;

    _clearOtpError();

    final digits = _extractDigits(value);

    if (digits.isEmpty) {
      if (_otpControllers[index].text.isNotEmpty) {
        _otpControllers[index].clear();
      }

      setState(() {});
      return;
    }

    // ----------------------------------------------------------
    // PASTE / AUTOFILL
    // ----------------------------------------------------------

    if (digits.length > 1) {
      _handleOtpPaste(digits, index);
      return;
    }

    // ----------------------------------------------------------
    // SINGLE DIGIT
    // ----------------------------------------------------------

    _setOtpDigit(index, digits);

    if (index < otpLength - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    } else {
      _otpFocusNodes[index].unfocus();
      _scheduleAutoVerify();
    }

    setState(() {});
  }

  void _setOtpDigit(int index, String digit) {
    _otpControllers[index].value = TextEditingValue(
      text: digit,
      selection: const TextSelection.collapsed(offset: 1),
    );
  }

  // ============================================================
  // PASTE / AUTOFILL
  // ============================================================

  void _handleOtpPaste(String value, int startIndex) {
    if (!mounted) return;

    final digits = _extractDigits(value);

    if (digits.isEmpty) return;

    final normalized = digits.length > otpLength
        ? digits.substring(0, otpLength)
        : digits;

    // If a complete OTP is pasted anywhere,
    // fill all six fields.
    if (normalized.length == otpLength) {
      for (int i = 0; i < otpLength; i++) {
        _setOtpDigit(i, normalized[i]);
      }

      _otpFocusNodes.last.unfocus();

      setState(() {});

      _scheduleAutoVerify();
      return;
    }

    // Partial paste.
    for (int i = startIndex; i < otpLength; i++) {
      _otpControllers[i].clear();
    }

    final available = otpLength - startIndex;

    final pasteDigits = normalized.length > available
        ? normalized.substring(0, available)
        : normalized;

    for (int i = 0; i < pasteDigits.length; i++) {
      _setOtpDigit(startIndex + i, pasteDigits[i]);
    }

    final lastIndex = startIndex + pasteDigits.length - 1;

    if (lastIndex < otpLength - 1) {
      _otpFocusNodes[lastIndex + 1].requestFocus();
    } else {
      _otpFocusNodes.last.unfocus();
      _scheduleAutoVerify();
    }

    setState(() {});
  }

  // ============================================================
  // BACKSPACE
  // ============================================================

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event, int index) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    _clearOtpError();

    final currentValue = _otpControllers[index].text;

    if (currentValue.isNotEmpty) {
      _otpControllers[index].clear();

      setState(() {});

      return KeyEventResult.handled;
    }

    if (index > 0) {
      final previousIndex = index - 1;

      _otpControllers[previousIndex].clear();
      _otpFocusNodes[previousIndex].requestFocus();

      setState(() {});

      return KeyEventResult.handled;
    }

    return KeyEventResult.handled;
  }

  // ============================================================
  // AUTO VERIFY
  // ============================================================

  void _scheduleAutoVerify() {
    if (!_isOtpComplete() ||
        _isVerifying ||
        _isResending ||
        _autoVerifyScheduled) {
      return;
    }

    _autoVerifyScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoVerifyScheduled = false;

      if (!mounted) return;

      if (_isOtpComplete() && !_isVerifying && !_isResending) {
        _verifyOtp();
      }
    });
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    if (_isVerifying || _isResending) return;

    FocusScope.of(context).unfocus();

    if (!_isOtpComplete()) {
      const message = 'Please enter the complete 6-digit code.';

      _setOtpError(message);

      return;
    }

    setState(() {
      _isVerifying = true;
      _hasOtpError = false;
      _otpErrorMessage = null;
    });

    try {
      final response = await AuthService.verifyEmailOtp(
        email: widget.email,
        token: _getOtp(),
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AccountCreatedScreen()),
        );

        return;
      }

      const message = 'Email verification failed. Please try again.';

      _setOtpError(message);

      _focusOtpForCorrection();
    } on AuthException catch (error) {
      if (!mounted) return;

      final message = _getAuthErrorMessage(error);

      _setOtpError(message);

      _focusOtpForCorrection();
    } catch (_) {
      if (!mounted) return;

      const message = 'Something went wrong. Please try again.';

      _setOtpError(message);

      _focusOtpForCorrection();
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _focusOtpForCorrection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _otpFocusNodes.first.requestFocus();
    });
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0 || _isResending || _isVerifying) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isResending = true;
      _hasOtpError = false;
      _otpErrorMessage = null;
    });

    try {
      await AuthService.resendVerificationOtp(email: widget.email);

      if (!mounted) return;

      _clearOtp(requestFocus: false);

      _startResendTimer();

      _showMessage('A new verification code has been sent.', isError: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _otpFocusNodes.first.requestFocus();
        }
      });
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(_getAuthErrorMessage(error), isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to resend the code. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  // ============================================================
  // AUTH ERROR MESSAGES
  // ============================================================

  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('expired')) {
      return 'This code has expired. Please request a new one.';
    }

    if (message.contains('invalid') || message.contains('token')) {
      return 'Incorrect code. Please check your email and try again.';
    }

    if (message.contains('confirmed') || message.contains('verified')) {
      return 'This email address is already verified.';
    }

    if (message.contains('rate limit') ||
        message.contains('too many') ||
        message.contains('429')) {
      return 'Too many attempts. Please wait and try again.';
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('internet')) {
      return 'Network error. Please check your internet connection.';
    }

    // Auth could not deliver the email at all (SMTP failure, broken
    // template, rate limit) - not a problem with the entered code.
    if (error.code == 'unexpected_failure' ||
        message.contains('error sending confirmation email') ||
        message.contains('unexpected_failure')) {
      return 'We could not send the verification email. '
          'Please wait a minute and try again.';
    }

    return 'Verification failed. Please check the code and try again.';
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? errorRed : primaryGreen,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // OTP BOX
  // ============================================================

  Widget _buildOtpBox(int index) {
    final isFilled = _otpControllers[index].text.isNotEmpty;

    final border = _hasOtpError ? errorRed : borderColor;

    final focusedBorder = _hasOtpError ? errorRed : primaryGreen;

    final fill = _hasOtpError
        ? errorBackground
        : isFilled
        ? softGreen
        : Colors.white.withValues(alpha: 0.94);

    return Semantics(
      label: 'Verification code digit ${index + 1}',
      child: SizedBox(
        width: 46,
        height: 56,
        child: Focus(
          onKeyEvent: (node, event) => _handleKeyEvent(node, event, index),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            enabled: !_isVerifying && !_isResending,

            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),

            textInputAction: index == otpLength - 1
                ? TextInputAction.done
                : TextInputAction.next,

            textAlign: TextAlign.center,

            autofillHints: index == 0
                ? const [AutofillHints.oneTimeCode]
                : null,

            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],

            cursorColor: primaryGreen,

            style: TextStyle(
              color: _hasOtpError ? errorRed : darkText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),

            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: fill,

              contentPadding: EdgeInsets.zero,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 1.2),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 1.2),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: focusedBorder, width: 2),
              ),

              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border, width: 1.2),
              ),
            ),

            onChanged: (value) {
              _onOtpChanged(value, index);
            },

            onTap: _clearOtpError,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL DISPLAY
  // ============================================================

  Widget _buildEmailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: softGreenBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: primaryGreen,
              size: 19,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification email sent to',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESEND SECTION
  // ============================================================

  Widget _buildResendSection() {
    final canResend = _secondsRemaining == 0 && !_isResending && !_isVerifying;

    return Column(
      children: [
        const Text(
          'Didn’t receive the code?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: secondaryText,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 7),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: canResend ? _resendOtp : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  _isResending ? 'Sending...' : 'Resend code',
                  key: ValueKey(_isResending),
                  style: TextStyle(
                    color: canResend ? primaryGreen : mutedText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: canResend
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: primaryGreen,
                  ),
                ),
              ),
            ),

            if (_secondsRemaining > 0) ...[
              const SizedBox(width: 7),
              Text(
                'in ${_formatTime(_secondsRemaining)}',
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ============================================================
  // VERIFY BUTTON
  // ============================================================

  Widget _buildVerifyButton() {
    final enabled = !_isVerifying && !_isResending;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [primaryGreen, Color(0xFF13A847)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFA8BBB0), Color(0xFFA8BBB0)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? _verifyOtp : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isVerifying
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Verify email',
                        key: ValueKey('verify'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  Widget _buildErrorMessage() {
    if (!_hasOtpError) {
      return const SizedBox(height: 18);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: errorRed, size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _otpErrorMessage ?? 'Verification failed.',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: errorRed,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // The scaffold does not resize for the keyboard, so the scroll view pads
    // itself with the keyboard height to keep the OTP fields reachable.
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ------------------------------------------------------
          // BACKGROUND
          // ------------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ------------------------------------------------------
          // CONTENT
          // ------------------------------------------------------
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(24, 18, 24, 120 + keyboardInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 138,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ------------------------------------------------
                            // ILLUSTRATION
                            // ------------------------------------------------
                            const SizedBox(height: 50),

                            const SizedBox(
                              width: 225,
                              height: 160,
                              child: Image(
                                image: AssetImage(
                                  'assets/images/email_verification.png',
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ------------------------------------------------
                            // TITLE
                            // ------------------------------------------------
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Verify ',
                                    style: TextStyle(color: primaryGreen),
                                  ),
                                  TextSpan(
                                    text: 'Your Email',
                                    style: TextStyle(color: darkText),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 9),

                            // ------------------------------------------------
                            // DESCRIPTION
                            // ------------------------------------------------
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'We’ve sent a 6-digit verification code to your email address.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // EMAIL CARD
                            // ------------------------------------------------
                            _buildEmailCard(),

                            const SizedBox(height: 25),

                            // ------------------------------------------------
                            // OTP LABEL
                            // ------------------------------------------------
                            const Text(
                              'Enter verification code',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: darkText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 13),

                            // ------------------------------------------------
                            // OTP FIELDS
                            // ------------------------------------------------
                            AutofillGroup(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(otpLength, (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index == otpLength - 1 ? 0 : 7,
                                    ),
                                    child: _buildOtpBox(index),
                                  );
                                }),
                              ),
                            ),

                            // ------------------------------------------------
                            // ERROR
                            // ------------------------------------------------
                            _buildErrorMessage(),

                            const SizedBox(height: 17),

                            // ------------------------------------------------
                            // RESEND
                            // ------------------------------------------------
                            _buildResendSection(),

                            const SizedBox(height: 25),

                            // ------------------------------------------------
                            // VERIFY
                            // ------------------------------------------------
                            _buildVerifyButton(),

                            const SizedBox(height: 14),

                            // ------------------------------------------------
                            // CHANGE EMAIL
                            // ------------------------------------------------
                            TextButton(
                              onPressed: (_isVerifying || _isResending)
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                'Change email',
                                style: TextStyle(
                                  color: (_isVerifying || _isResending)
                                      ? mutedText
                                      : primaryGreen,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ------------------------------------------------------
          // GRASS DECORATION
          // ------------------------------------------------------
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
