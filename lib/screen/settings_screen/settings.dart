import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.mainBackground,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Settings",
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Customize your sanctuary experience.",
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                        const SizedBox(height: 40),

                        _sectionLabel("GENERAL"),
                        _buildSettingToggle("Push Notifications", "Receive gentle reminders", _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
                        _buildSettingToggle("Dark Mode", "Keep the sanctuary dim", _darkMode, (v) => setState(() => _darkMode = v)),
                        
                        const SizedBox(height: 30),
                        _sectionLabel("ACCOUNT"),
                        _buildSettingItem("Privacy Policy", Icons.privacy_tip_outlined),
                        _buildSettingItem("Terms of Service", Icons.description_outlined),
                        _buildSettingItem("Help & Support", Icons.help_outline),

                        const SizedBox(height: 40),
                        _buildVersionInfo(),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Sanctuary",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.accentLavender, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentLavender,
            activeTrackColor: AppColors.accentLavender.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return const Center(
      child: Column(
        children: [
          Text("Sanctuary v1.0.0", style: TextStyle(color: Colors.white24, fontSize: 12)),
          SizedBox(height: 4),
          Text("Made with peace & code", style: TextStyle(color: Colors.white12, fontSize: 10)),
        ],
      ),
    );
  }
}
