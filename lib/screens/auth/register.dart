import 'package:flutter/material.dart';
import 'package:poshiva/screens/auth/verify_email.dart';
import 'package:poshiva/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;
  bool isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    // ------------------------------------------------------------
    // Prevent duplicate requests
    // ------------------------------------------------------------

    if (isLoading) {
      return;
    }

    // ------------------------------------------------------------
    // Validate form
    // ------------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ------------------------------------------------------------
    // Validate Terms & Conditions
    // ------------------------------------------------------------

    if (!agreeToTerms) {
      _showError('Please agree to the Terms & Conditions and Privacy Policy.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // Get form values
      // ----------------------------------------------------------

      final fullName = fullNameController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text;

      // ----------------------------------------------------------
      // Register through AuthService
      // ----------------------------------------------------------

      final response = await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // IMPORTANT:
      //
      // When Supabase email confirmation is enabled:
      //
      // response.user != null
      // response.session == null
      //
      // This is NORMAL.
      //
      // The user must verify the email before getting an
      // authenticated session.
      // ----------------------------------------------------------

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
        );
      } else {
        _showError('We could not create your account. Please try again.');
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      _showError(_getAuthErrorMessage(error));
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Something went wrong. Please check your internet connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // AUTH ERROR MESSAGE
  // ============================================================

  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    // ------------------------------------------------------------
    // Email already exists
    // ------------------------------------------------------------

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }

    // ------------------------------------------------------------
    // Invalid email
    // ------------------------------------------------------------

    if (message.contains('invalid email') ||
        message.contains('invalid') && message.contains('email')) {
      return 'Please enter a valid email address.';
    }

    // ------------------------------------------------------------
    // Password problems
    // ------------------------------------------------------------

    if (message.contains('password')) {
      return 'Your password does not meet the required security rules.';
    }

    // ------------------------------------------------------------
    // Rate limit
    // ------------------------------------------------------------

    if (message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // ------------------------------------------------------------
    // Network
    // ------------------------------------------------------------

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }

    // ------------------------------------------------------------
    // Generic
    // ------------------------------------------------------------

    return 'We could not create your account. Please try again.';
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
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
          // MAIN CONTENT
          // ======================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        children: [
                          const SizedBox(height: 18),

                          // ==================================================
                          // LOGO
                          // ==================================================
                          Image.asset(
                            'assets/images/login_logo.png',
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 7),

                          // ==================================================
                          // APP NAME
                          // ==================================================
                          const Text(
                            'Poshiva',
                            style: TextStyle(
                              color: Color(0xFF287D31),
                              fontSize: 35,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),

                          const SizedBox(height: 3),

                          // ==================================================
                          // TAGLINE
                          // ==================================================
                          const Text(
                            'Share More. Waste Less. Help Everyone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // TITLE
                          // ==================================================
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Create Your ',
                                  style: TextStyle(
                                    color: Color(0xFF078D3B),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Account',
                                  style: TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 7),

                          // ==================================================
                          // DESCRIPTION
                          // ==================================================
                          const Text(
                            'Join Poshiva and be a part of a community\n'
                            'that cares.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF737B8C),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // FORM
                          // ==================================================
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // ==========================================
                                // FULL NAME
                                // ==========================================
                                _buildTextField(
                                  controller: fullNameController,
                                  hintText: 'Full Name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final name = value?.trim() ?? '';

                                    if (name.isEmpty) {
                                      return 'Please enter your full name';
                                    }

                                    if (name.length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }

                                    if (name.length > 60) {
                                      return 'Name must be less than 60 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // ==========================================
                                // EMAIL
                                // ==========================================
                                _buildTextField(
                                  controller: emailController,
                                  hintText: 'Email Address',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';

                                    if (email.isEmpty) {
                                      return 'Please enter your email address';
                                    }

                                    final emailRegex = RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    );

                                    if (!emailRegex.hasMatch(email)) {
                                      return 'Please enter a valid email address';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // ==========================================
                                // PASSWORD
                                // ==========================================
                                _buildTextField(
                                  controller: passwordController,
                                  hintText: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final password = value ?? '';

                                    if (password.isEmpty) {
                                      return 'Please enter a password';
                                    }

                                    if (password.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }

                                    if (!RegExp(r'[A-Z]').hasMatch(password)) {
                                      return 'Include at least one uppercase letter';
                                    }

                                    if (!RegExp(r'[a-z]').hasMatch(password)) {
                                      return 'Include at least one lowercase letter';
                                    }

                                    if (!RegExp(r'[0-9]').hasMatch(password)) {
                                      return 'Include at least one number';
                                    }

                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFFB8BDC5),
                                      size: 21,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // ==========================================
                                // CONFIRM PASSWORD
                                // ==========================================
                                _buildTextField(
                                  controller: confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }

                                    if (value != passwordController.text) {
                                      return 'Passwords do not match';
                                    }

                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFFB8BDC5),
                                      size: 21,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // TERMS
                          // ==================================================
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      agreeToTerms = !agreeToTerms;
                                    });
                                  },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 21,
                                  height: 21,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF078D3B),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: agreeToTerms
                                      ? const Icon(
                                          Icons.check,
                                          size: 15,
                                          color: Color(0xFF078D3B),
                                        )
                                      : null,
                                ),

                                const SizedBox(width: 9),

                                const Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        color: Color(0xFF737B8C),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(text: 'I agree to the '),
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(
                                            color: Color(0xFF078D3B),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: '\nand '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: Color(0xFF078D3B),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // CREATE ACCOUNT BUTTON
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF078D3B),
                                    Color(0xFF13A847),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
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
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: isLoading ? null : _createAccount,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (isLoading)
                                        const SizedBox(
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
                                      else
                                        const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                      if (!isLoading)
                                        Positioned(
                                          right: 10,
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Color(0xFF078D3B),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // LOGIN
                          // ==================================================
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: Color(0xFF737B8C),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: Color(0xFF078D3B),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF078D3B),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // BOTTOM GRASS
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

  // ============================================================
  // REUSABLE TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      cursorColor: const Color(0xFF078D3B),
      style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF596273),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF596273), size: 22),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),

        // --------------------------------------------------------
        // NORMAL BORDER
        // --------------------------------------------------------
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFD5D9DF), width: 1.2),
        ),

        // --------------------------------------------------------
        // FOCUSED BORDER
        // --------------------------------------------------------
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF159447), width: 1.4),
        ),

        // --------------------------------------------------------
        // ERROR BORDER
        // --------------------------------------------------------
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
        ),

        // --------------------------------------------------------
        // FOCUSED ERROR BORDER
        // --------------------------------------------------------
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.4),
        ),
      ),
    );
  }
}
