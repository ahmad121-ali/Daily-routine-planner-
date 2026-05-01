import 'package:flutter/material.dart';
import '../signup_screen/sign_up.dart';
import '../../theme/linear_gradient.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isGuestLoading = false;
  bool _isKeepLoggedIn = false;
  bool _obscurePassword = true; // Logic for password visibility

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleGuestLogin() async {
    if (_isLoading || _isGuestLoading) return;
    
    setState(() => _isGuestLoading = true);
    try {
      await _authService.signInAnonymously();
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains("admin-restricted-operation") || errorMessage.contains("provider-disabled")) {
          errorMessage = "Guest access is disabled. Please enable 'Anonymous' sign-in in your Firebase Console.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.mainBackground)),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Welcome back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      const Text("Sign in to continue.", style: TextStyle(color: Colors.white60, fontSize: 16)),
                      const SizedBox(height: 40),

                      _buildTextField(label: "Email Address", hint: "name@example.com", icon: Icons.email_outlined, controller: _emailController, validator: _validateEmail),
                      const SizedBox(height: 24),
                      
                      // Updated Password Field with Eye Icon
                      _buildPasswordField(_passwordController),
                      
                      const SizedBox(height: 16),
                      _buildKeepLoggedIn(),
                      const SizedBox(height: 32),

                      _isLoading 
                        ? const CircularProgressIndicator(color: AppColors.accentLavender)
                        : _buildSignInButton(),

                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildGoogleButton(),
                      const SizedBox(height: 16),

                      _isGuestLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentLavender))
                        : _buildGuestButton(),

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                            child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeepLoggedIn() {
    return GestureDetector(
      onTap: () => setState(() => _isKeepLoggedIn = !_isKeepLoggedIn),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isKeepLoggedIn ? AppColors.accentLavender : Colors.black.withAlpha(102), // 0.4 * 255 = 102
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: _isKeepLoggedIn ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          const Text("Keep me logged in", style: TextStyle(color: Colors.white60, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required IconData icon, required TextEditingController controller, required String? Function(String?) validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            filled: true,
            fillColor: Colors.black.withAlpha(102), // 0.4 * 255 = 102
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            errorStyle: const TextStyle(color: Colors.orangeAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword, // Dynamic visibility
          validator: _validatePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword; // Toggle visibility
                });
              },
            ),
            filled: true,
            fillColor: Colors.black.withAlpha(102), // 0.4 * 255 = 102
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            errorStyle: const TextStyle(color: Colors.orangeAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.primaryButtonGradient, borderRadius: BorderRadius.circular(30)),
        child: ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
          child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.socialButtonGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ElevatedButton(
          onPressed: () {}, // Placeholder
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata, color: Colors.white, size: 30),
              SizedBox(width: 8),
              Text("Continue with Google", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestButton() {
    return TextButton(
      onPressed: _handleGuestLogin,
      child: const Text("Continue as a guest", style: TextStyle(color: AppColors.accentLavender, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.white10, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("OR", style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: Colors.white10, thickness: 1)),
      ],
    );
  }
}
