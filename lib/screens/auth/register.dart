import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // FOCUS NODES
  // ============================================================

  final FocusNode fullNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  // ============================================================
  // STATE
  // ============================================================

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;
  bool isLoading = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF078D3B);
  static const Color secondaryGreen = Color(0xFF13A847);

  static const Color darkText = Color(0xFF202020);
  static const Color bodyText = Color(0xFF737B8C);
  static const Color inputText = Color(0xFF333333);
  static const Color borderColor = Color(0xFFD5D9DF);
  static const Color errorColor = Color(0xFFD32F2F);

  // ============================================================
  // VALIDATION REGEX
  // ============================================================

  // IMPORTANT:
  // Correct email regex for a Dart raw string.
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');

  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');

  static final RegExp _numberRegex = RegExp(r'[0-9]');

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  // ============================================================
  // PASSWORD STATE
  // ============================================================

  void _onPasswordChanged() {
    if (!mounted) return;

    if (confirmPasswordController.text.isNotEmpty) {
      setState(() {});
    }
  }

  void _onConfirmPasswordChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  bool get _isPasswordValid {
    final password = passwordController.text;

    return password.length >= 8 &&
        _uppercaseRegex.hasMatch(password) &&
        _lowercaseRegex.hasMatch(password) &&
        _numberRegex.hasMatch(password);
  }

  // ============================================================
  // CONFIRM PASSWORD VALIDATION
  // ============================================================

  bool get _isConfirmPasswordValid {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    return confirmPassword.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword;
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    // ----------------------------------------------------------
    // PREVENT DOUBLE SUBMISSION
    // ----------------------------------------------------------

    if (isLoading) {
      return;
    }

    // ----------------------------------------------------------
    // HIDE KEYBOARD
    // ----------------------------------------------------------

    FocusScope.of(context).unfocus();

    // ----------------------------------------------------------
    // FORM VALIDATION
    // ----------------------------------------------------------

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    // ----------------------------------------------------------
    // TERMS VALIDATION
    // ----------------------------------------------------------

    if (!agreeToTerms) {
      _showError('Please agree to the Terms & Conditions and Privacy Policy.');
      return;
    }

    // ----------------------------------------------------------
    // PASSWORD VALIDATION
    // ----------------------------------------------------------

    if (!_isPasswordValid) {
      _showError('Please meet all password requirements.');
      return;
    }

    // ----------------------------------------------------------
    // CONFIRM PASSWORD VALIDATION
    // ----------------------------------------------------------

    if (!_isConfirmPasswordValid) {
      _showError('Passwords do not match.');
      return;
    }

    // ----------------------------------------------------------
    // READ VALUES
    // ----------------------------------------------------------

    final String fullName = fullNameController.text.trim();

    final String email = emailController.text.trim().toLowerCase();

    final String password = passwordController.text;

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // FINISH AUTOFILL
      // --------------------------------------------------------

      TextInput.finishAutofillContext(shouldSave: true);

      // --------------------------------------------------------
      // REGISTER WITH SUPABASE
      // --------------------------------------------------------

      final AuthResponse response = await AuthService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // USER CREATED
      // --------------------------------------------------------

      final User? user = response.user;

      if (user == null) {
        _showError('We could not create your account. Please try again.');
        return;
      }

      // --------------------------------------------------------
      // IMPORTANT:
      //
      // DO NOT CHECK response.session HERE.
      //
      // If Supabase "Confirm Email" is enabled:
      //
      // response.user    -> available
      // response.session -> can be null
      //
      // This is expected.
      // --------------------------------------------------------

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showError(_getAuthErrorMessage(error));
    } catch (error, stackTrace) {
      // --------------------------------------------------------
      // LOG UNEXPECTED ERROR
      // --------------------------------------------------------

      debugPrint('POSHIVA REGISTER ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      _showError('Something went wrong. Please try again.');
    } finally {
      // Never `return` inside `finally` - it would swallow any pending
      // exception or result from the try/catch blocks above.
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
    final String message = error.message.trim().toLowerCase();

    debugPrint('POSHIVA SUPABASE AUTH ERROR: ${error.message}');

    // ----------------------------------------------------------
    // EXISTING ACCOUNT
    // ----------------------------------------------------------

    if (message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('email already registered')) {
      return 'An account with this email already exists. '
          'Please log in instead.';
    }

    // ----------------------------------------------------------
    // INVALID EMAIL
    // ----------------------------------------------------------

    if (message.contains('invalid email') ||
        message.contains('email address is invalid')) {
      return 'Please enter a valid email address.';
    }

    // ----------------------------------------------------------
    // PASSWORD
    // ----------------------------------------------------------

    if (message.contains('password')) {
      return 'Your password does not meet the required '
          'security rules.';
    }

    // ----------------------------------------------------------
    // RATE LIMIT
    // ----------------------------------------------------------

    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('over_email_send_rate_limit')) {
      return 'Too many attempts. Please wait a moment '
          'and try again.';
    }

    // ----------------------------------------------------------
    // SIGN UP DISABLED
    // ----------------------------------------------------------

    if (message.contains('signups not allowed') ||
        message.contains('signup is disabled') ||
        message.contains('sign up is disabled')) {
      return 'New account registration is currently '
          'unavailable.';
    }

    // ----------------------------------------------------------
    // NETWORK
    // ----------------------------------------------------------

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket') ||
        message.contains('timeout')) {
      return 'Network error. Please check your internet '
          'connection.';
    }

    // ----------------------------------------------------------
    // EMAIL PROVIDER
    // ----------------------------------------------------------

    if (message.contains('email provider') || message.contains('smtp')) {
      return 'We could not send the verification email. '
          'Please try again later.';
    }

    // ----------------------------------------------------------
    // SUPABASE COULD NOT SEND THE CONFIRMATION EMAIL
    //
    // Auth answers 500 unexpected_failure when it cannot deliver the
    // email (SMTP failure, broken email template, rate limit, ...).
    // The account itself may already exist, so surface a clear
    // message instead of the raw payload.
    // ----------------------------------------------------------

    if (error.code == 'unexpected_failure' ||
        message.contains('error sending confirmation email') ||
        message.contains('unexpected_failure')) {
      return 'We could not send your verification email. '
          'Please wait a minute and try again.';
    }

    // ----------------------------------------------------------
    // FALLBACK
    // ----------------------------------------------------------

    final String raw = error.message.trim();

    // Never show a raw payload (JSON/HTML) to the user.
    if (raw.isNotEmpty &&
        !raw.startsWith('{') &&
        !raw.startsWith('[') &&
        !raw.startsWith('<')) {
      return raw;
    }

    return 'Unable to create your account. Please try again.';
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: errorColor,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      validator: validator,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: primaryGreen,
      enabled: !isLoading,

      style: const TextStyle(
        color: inputText,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: const TextStyle(
          color: Color(0xFF9AA1AB),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        // IMPORTANT:
        // Use the icon passed to this function.
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF9AA1AB), size: 21),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: Colors.white.withValues(alpha: 0.92),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1.1),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1.1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.2),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),

        errorStyle: const TextStyle(
          color: errorColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD VISIBILITY BUTTON
  // ============================================================

  Widget _buildPasswordVisibilityButton({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: obscure ? 'Show password' : 'Hide password',

      onPressed: isLoading ? null : onPressed,

      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFF9AA1AB),
        size: 21,
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTerms() {
    return Semantics(
      label: 'Agree to Terms and Privacy Policy',
      checked: agreeToTerms,
      button: true,

      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                setState(() {
                  agreeToTerms = !agreeToTerms;
                });
              },

        borderRadius: BorderRadius.circular(10),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),

                curve: Curves.easeOut,

                width: 21,
                height: 21,

                margin: const EdgeInsets.only(top: 1),

                decoration: BoxDecoration(
                  color: agreeToTerms ? primaryGreen : Colors.white,

                  borderRadius: BorderRadius.circular(6),

                  border: Border.all(
                    color: agreeToTerms
                        ? primaryGreen
                        : const Color(0xFFBFC8C3),
                    width: 1.4,
                  ),
                ),

                child: agreeToTerms
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: bodyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),

                    children: [
                      TextSpan(text: 'I agree to the '),

                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      TextSpan(text: ' and '),

                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: primaryGreen,
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
      ),
    );
  }

  // ============================================================
  // CREATE ACCOUNT BUTTON
  // ============================================================

  Widget _buildCreateAccountButton() {
    return Semantics(
      button: true,
      enabled: !isLoading,
      label: 'Create Poshiva account',

      child: SizedBox(
        width: double.infinity,
        height: 54,

        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryGreen, secondaryGreen],
            ),

            borderRadius: BorderRadius.circular(13),

            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.20),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: isLoading ? null : _createAccount,

              borderRadius: BorderRadius.circular(13),

              child: Stack(
                alignment: Alignment.center,

                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,

                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,

                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        width: 30,
                        height: 30,

                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: primaryGreen,
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
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // The scaffold does not resize for the keyboard, so the scroll view has
    // to pad itself with the keyboard height, otherwise the lower fields
    // (confirm password, submit button) stay hidden behind the keyboard.
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AutofillGroup(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,

                    padding: EdgeInsets.fromLTRB(
                      38,
                      25,
                      38,
                      110 + keyboardInset,
                    ),

                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 25,
                      ),

                      child: Column(
                        children: [
                          // ==================================================
                          // LOGO
                          // ==================================================
                          Image.asset(
                            'assets/images/login_logo.png',

                            width: 68,
                            height: 68,

                            fit: BoxFit.contain,

                            semanticLabel: 'Poshiva logo',
                          ),

                          const SizedBox(height: 6),

                          // ==================================================
                          // APP NAME
                          // ==================================================
                          const Text(
                            'Poshiva',

                            style: TextStyle(
                              color: Color(0xFF287D31),
                              fontSize: 34,
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
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 27),

                          // ==================================================
                          // TITLE
                          // ==================================================
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Create Your ',

                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                TextSpan(
                                  text: 'Account',

                                  style: TextStyle(
                                    color: darkText,
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
                              color: bodyText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 27),

                          // ==================================================
                          // FORM
                          // ==================================================
                          Form(
                            key: _formKey,

                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,

                            child: Column(
                              children: [
                                // ==========================================
                                // FULL NAME
                                // ==========================================
                                _buildTextField(
                                  controller: fullNameController,

                                  focusNode: fullNameFocusNode,

                                  hintText: 'Full Name',

                                  prefixIcon: Icons.person_outline_rounded,

                                  textInputAction: TextInputAction.next,

                                  textCapitalization: TextCapitalization.words,

                                  autofillHints: const [AutofillHints.name],

                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(60),
                                  ],

                                  onFieldSubmitted: (_) {
                                    emailFocusNode.requestFocus();
                                  },

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

                                  focusNode: emailFocusNode,

                                  hintText: 'Email Address',

                                  prefixIcon: Icons.mail_outline_rounded,

                                  keyboardType: TextInputType.emailAddress,

                                  textInputAction: TextInputAction.next,

                                  autofillHints: const [AutofillHints.email],

                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),

                                    LengthLimitingTextInputFormatter(254),
                                  ],

                                  onFieldSubmitted: (_) {
                                    passwordFocusNode.requestFocus();
                                  },

                                  validator: (value) {
                                    final email = value?.trim() ?? '';

                                    if (email.isEmpty) {
                                      return 'Please enter your email address';
                                    }

                                    if (!_emailRegex.hasMatch(email)) {
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

                                  focusNode: passwordFocusNode,

                                  hintText: 'Password',

                                  prefixIcon: Icons.lock_outline_rounded,

                                  obscureText: obscurePassword,

                                  textInputAction: TextInputAction.next,

                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],

                                  suffixIcon: _buildPasswordVisibilityButton(
                                    obscure: obscurePassword,

                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                  ),

                                  onFieldSubmitted: (_) {
                                    confirmPasswordFocusNode.requestFocus();
                                  },

                                  validator: (value) {
                                    final password = value ?? '';

                                    if (password.isEmpty) {
                                      return 'Please enter a password';
                                    }

                                    if (password.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }

                                    if (!_uppercaseRegex.hasMatch(password)) {
                                      return 'Password must contain an uppercase letter';
                                    }

                                    if (!_lowercaseRegex.hasMatch(password)) {
                                      return 'Password must contain a lowercase letter';
                                    }

                                    if (!_numberRegex.hasMatch(password)) {
                                      return 'Password must contain a number';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // ==========================================
                                // CONFIRM PASSWORD
                                // ==========================================
                                _buildTextField(
                                  controller: confirmPasswordController,

                                  focusNode: confirmPasswordFocusNode,

                                  hintText: 'Confirm Password',

                                  prefixIcon: Icons.lock_outline_rounded,

                                  obscureText: obscureConfirmPassword,

                                  textInputAction: TextInputAction.done,

                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],

                                  suffixIcon: _buildPasswordVisibilityButton(
                                    obscure: obscureConfirmPassword,

                                    onPressed: () {
                                      setState(() {
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword;
                                      });
                                    },
                                  ),

                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).unfocus();

                                    if (_isConfirmPasswordValid &&
                                        agreeToTerms) {
                                      _createAccount();
                                    }
                                  },

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }

                                    if (value != passwordController.text) {
                                      return 'Passwords do not match';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 19),

                                // ==========================================
                                // TERMS
                                // ==========================================
                                _buildTerms(),

                                const SizedBox(height: 20),

                                // ==========================================
                                // CREATE ACCOUNT
                                // ==========================================
                                _buildCreateAccountButton(),

                                const SizedBox(height: 17),

                                // ==========================================
                                // LOGIN
                                // ==========================================
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          FocusScope.of(context).unfocus();

                                          Navigator.of(context).pop();
                                        },

                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),

                                    child: Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          color: bodyText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),

                                        children: [
                                          TextSpan(
                                            text: 'Already have an account? ',
                                          ),

                                          TextSpan(
                                            text: 'Login',

                                            style: TextStyle(
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),

                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);

    confirmPasswordController.removeListener(_onConfirmPasswordChanged);

    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.dispose();
  }
}
