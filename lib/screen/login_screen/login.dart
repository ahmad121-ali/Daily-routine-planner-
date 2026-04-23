import 'package:flutter/material.dart';
import '../home_screen/home.dart';
import '../signup_screen/sign_up.dart';
import '../../theme/linear_gradient.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Gradient using central variable
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.mainBackground,
            ),
          ),

          // 2. The Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardFill,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome back",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign in to continue your journey.",
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    _buildTextField("Email Address", "name@example.com", Icons.email_outlined),
                    const SizedBox(height: 24),

                    _buildPasswordField(),
                    const SizedBox(height: 16),

                    _buildKeepLoggedIn(),
                    const SizedBox(height: 32),

                    _buildSignInButton(context),
                    const SizedBox(height: 30),

                    _buildDivider(),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(child: _buildSocialButton("Google", Icons.g_mobiledata)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSocialButton("Apple", Icons.apple)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Colors.white60)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: const Text(
                            "Create account",
                            style: TextStyle(color: AppColors.accentLavender, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const HomeScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text(
            "Sign In",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          gradient: AppColors.socialButtonGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.4),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Password", style: TextStyle(color: Colors.white70, fontSize: 14)),
            GestureDetector(
              onTap: () {},
              child: const Text("Forgot Password?", style: TextStyle(color: AppColors.accentLavender, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.4),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildKeepLoggedIn() {
    return Row(
      children: [
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: AppColors.cardBorder)
          ),
        ),
        const SizedBox(width: 10),
        const Text("Keep me logged in", style: TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.cardBorder)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("OR CONTINUE WITH", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.1)),
        ),
        Expanded(child: Divider(color: AppColors.cardBorder)),
      ],
    );
  }

  Widget _buildFooter() {
    return const Positioned(
      bottom: 30, left: 0, right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("PRIVACY", style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.2)),
          Text("TERMS", style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.2)),
          Text("SUPPORT", style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}
