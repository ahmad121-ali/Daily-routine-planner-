import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await _authService.getUserData();
    if (doc != null && doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['fullName'] ?? "";
        _emailController.text = data['email'] ?? _authService.currentUser?.email ?? "";
        _isInitialized = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isDark 
                ? AppColors.mainBackground 
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.purple.shade50, Colors.white, Colors.blue.shade50],
                  ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                Expanded(
                  child: !_isInitialized 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accentLavender))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87, 
                                fontSize: 36, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              "Refine your personal sanctuary details.",
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54, 
                                fontSize: 18
                              ),
                            ),
                            const SizedBox(height: 40),

                            _buildAvatarSection(),
                            const SizedBox(height: 40),

                            _buildTextField("Full Name", _nameController, Icons.person_outline, isDark),
                            const SizedBox(height: 24),

                            _buildTextField("Email Address", _emailController, Icons.email_outlined, isDark),
                            const SizedBox(height: 40),

                            _buildSaveButton(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white70 : Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Sanctuary",
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.accentLavender.withAlpha(51), // 0.2 * 255 = 51
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : "U",
              style: const TextStyle(color: AppColors.accentLavender, fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.accentPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54, size: 20),
            filled: true,
            fillColor: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13), // 0.05 * 255 = 12.75 -> 13
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: AppColors.accentLavender.withAlpha(77), blurRadius: 20, offset: const Offset(0, 10)) // 0.3 * 255 = 76.5 -> 77
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }
}
