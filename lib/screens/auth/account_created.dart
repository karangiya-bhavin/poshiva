import 'package:flutter/material.dart';
import 'login.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  // ==================================================
  // POSHIVA COLORS
  // ==================================================

  static const Color greenStart = Color(0xFF078D3B);
  static const Color greenEnd = Color(0xFF13A847);
  static const Color headingColor = Color(0xFF102B26);
  static const Color descriptionColor = Color(0xFF737B8C);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,

      // Keep background and grass fixed.
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // ==================================================
          // FIXED BACKGROUND
          // ==================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==================================================
          // MAIN CONTENT
          // ==================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Column(
                children: [
                  // --------------------------------------------------
                  // TOP SPACING
                  // --------------------------------------------------
                  const SizedBox(height: 40),

                  // --------------------------------------------------
                  // SUCCESS ILLUSTRATION
                  // --------------------------------------------------
                  Image.asset(
                    'assets/images/account_created.png',
                    width: screenWidth - 70,
                    height: 270,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 25),

                  // --------------------------------------------------
                  // SUCCESS TITLE
                  // --------------------------------------------------
                  const Text(
                    'Account Created',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: greenStart,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    'Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF202020),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 17),

                  // --------------------------------------------------
                  // DESCRIPTION
                  // --------------------------------------------------
                  const Text(
                    'Welcome to Poshiva!\n'
                    'Together, we can make a difference.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: descriptionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --------------------------------------------------
                  // GO TO LOGIN BUTTON
                  // --------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [greenStart, greenEnd],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: greenStart.withValues(alpha: 0.20),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),

                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },

                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Text(
                                'Go To Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              // Arrow circle
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
                                    color: greenStart,
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

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),

          // ==================================================
          // BOTTOM GRASS
          // ==================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/login_grass.png',
                width: screenWidth,
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
