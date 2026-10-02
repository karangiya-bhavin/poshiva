import 'package:flutter/material.dart';
import 'package:poshiva/screens/auth/verify_email.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Prevent the background and grass from moving
      // when the keyboard appears.
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // --------------------------------------------------
          // Background
          // --------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // --------------------------------------------------
          // Main Content
          // --------------------------------------------------
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: Column(
                    children: [
                      
                      // --------------------------------------------------
                      // Main Content Area
                      // --------------------------------------------------

                      const SizedBox(height: 25),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 18),

                            // --------------------------------------------------
                            // Poshiva Logo
                            // --------------------------------------------------
                            Image.asset(
                              'assets/images/login_logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 7),

                            // --------------------------------------------------
                            // App Name
                            // --------------------------------------------------
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

                            // --------------------------------------------------
                            // Tagline
                            // --------------------------------------------------
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

                            // --------------------------------------------------
                            // Create Your Account
                            // --------------------------------------------------
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

                            // --------------------------------------------------
                            // Description
                            // --------------------------------------------------
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

                            // --------------------------------------------------
                            // Full Name
                            // --------------------------------------------------
                            _buildTextField(
                              controller: fullNameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline_rounded,
                            ),

                            const SizedBox(height: 14),

                            // --------------------------------------------------
                            // Email
                            // --------------------------------------------------
                            _buildTextField(
                              controller: emailController,
                              hintText: 'Email Address',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 14),

                            // --------------------------------------------------
                            // Password
                            // --------------------------------------------------
                            _buildTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: obscurePassword,
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

                            // --------------------------------------------------
                            // Confirm Password
                            // --------------------------------------------------
                            _buildTextField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: obscureConfirmPassword,
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

                            const SizedBox(height: 20),

                            // --------------------------------------------------
                            // Terms & Conditions
                            // --------------------------------------------------
                            GestureDetector(
                              onTap: () {
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

                            // --------------------------------------------------
                            // Create Account Button
                            // --------------------------------------------------
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VerifyEmailScreen(
                                            email: emailController.text,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

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

                            // --------------------------------------------------
                            // Already Have Account
                            // --------------------------------------------------
                            GestureDetector(
                              onTap: () {
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // --------------------------------------------------
          // Bottom Grass
          // --------------------------------------------------
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

  // --------------------------------------------------
  // Reusable Text Field
  // --------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF078D3B),
        style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF596273),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF596273),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.82),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFFD5D9DF), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFF159447), width: 1.4),
          ),
        ),
      ),
    );
  }
}
