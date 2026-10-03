import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../auth/login.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  // ================================================
  // POSHIVA COLORS
  // ================================================
  static const Color primaryGreen = Color(0xFF07983E);
  static const Color buttonGreenStart = Color(0xFF0B8133);
  static const Color buttonGreenEnd = Color(0xFF14A045);
  static const Color headingColor = Color(0xFF222831);
  static const Color descriptionColor = Color(0xFF777777);
  static const Color inactiveDotColor = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            // ==========================================
            // BOTTOM WAVE
            // ==========================================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(
                'assets/vectors/onboarding_wave.svg',
                width: screenWidth,
                fit: BoxFit.fitWidth,
              ),
            ),

            // ==========================================
            // MAIN CONTENT
            // ==========================================
            // Wrapped in a scroll view that keeps at least the available
            // height: the pages used to overflow (and clip the button) on
            // small screens, while the Spacer still pushes the button to
            // the bottom on tall ones.
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // ======================================
                          // SKIP
                          // ======================================
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ======================================
                          // ILLUSTRATION
                          // ======================================
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Image.asset(
                              'assets/images/onboarding_3.png',
                              width: screenWidth - 40,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 35),

                          // ======================================
                          // PAGE INDICATOR
                          // ======================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildIndicator(false),
                              _buildIndicator(false),
                              _buildIndicator(true),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // ======================================
                          // TEXT SECTION
                          // ======================================
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 45,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  // ------------------------------
                                  // TITLE
                                  // ------------------------------
                                  Text(
                                    'Be Part of.\n'
                                    'The Journey.',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: headingColor,
                                      fontSize: 45,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),

                                  SizedBox(height: 18),

                                  // ------------------------------
                                  // DESCRIPTION
                                  // ------------------------------
                                  Text(
                                    'Donate food, request support,\n'
                                    'or help move food from one\n'
                                    'place to another.',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: descriptionColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // ======================================
                          // GET STARTED BUTTON
                          // ======================================
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),

                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },

                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          buttonGreenStart,
                                          buttonGreenEnd,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),

                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Get Started',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          SizedBox(width: 8),

                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================================================
  // PAGE INDICATOR
  // ================================================
  Widget _buildIndicator(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 7 : 6,
      height: active ? 7 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? primaryGreen : inactiveDotColor,
      ),
    );
  }
}
