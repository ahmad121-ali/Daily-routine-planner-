import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  void _showLogoutDialog() {
    final themeService = ThemeService();
    final isDark = themeService.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F36) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Logout", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text("Are you sure you want to leave your sanctuary?", 
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Stay", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _authService.signOut();
              navigator.pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final themeService = ThemeService();
        final isDark = themeService.isDarkMode;
        
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
                        colors: [
                          Colors.purple.shade50,
                          Colors.white,
                          Colors.blue.shade50,
                        ],
                      ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, isDark),
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: _authService.getUserDataStream(),
                        builder: (context, snapshot) {
                          String userName = "Sanctuary User";
                          String userEmail = _authService.currentUser?.email ?? "guest@sanctuary.com";
                          bool notificationsEnabled = true;
                          
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            userName = data['fullName'] ?? userName;
                            userEmail = data['email'] ?? userEmail;
                            notificationsEnabled = data['notificationsEnabled'] ?? true;
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87, 
                                    fontSize: 36, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "Customize your sanctuary experience.",
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.black54, 
                                    fontSize: 18
                                  ),
                                ),
                                const SizedBox(height: 40),

                                _sectionLabel("PROFILE"),
                                _buildProfileCard(userName, userEmail, isDark),
                                
                                const SizedBox(height: 30),
                                _sectionLabel("GENERAL"),
                                _buildSettingToggle(
                                  "Push Notifications", 
                                  "Receive gentle reminders", 
                                  notificationsEnabled, 
                                  (v) async {
                                    await _authService.updateNotificationPreference(v);
                                    if (v) {
                                      await _notificationService.requestPermissions();
                                    }
                                  },
                                  isDark
                                ),
                                _buildSettingToggle(
                                  "Dark Mode", 
                                  "Keep the sanctuary dim", 
                                  isDark, 
                                  (v) => themeService.setDarkMode(v),
                                  isDark
                                ),
                                
                                const SizedBox(height: 30),
                                _sectionLabel("ACCOUNT"),
                                _buildSettingItem("Privacy Policy", Icons.privacy_tip_outlined, isDark),
                                _buildSettingItem("Terms of Service", Icons.description_outlined, isDark),
                                _buildSettingItem("Help & Support", Icons.help_outline, isDark),
                                _buildSettingItem(
                                  "Logout", 
                                  Icons.logout, 
                                  isDark, 
                                  onTap: _showLogoutDialog,
                                  isLogout: true,
                                ),

                                const SizedBox(height: 40),
                                _buildVersionInfo(isDark),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(String name, String email, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/edit-profile'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13), // 0.05 * 255 = 12.75 -> 13
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(26) // 0.1 * 255 = 25.5 -> 26
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.accentLavender.withAlpha(51), // 0.2 * 255 = 51
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: const TextStyle(color: AppColors.accentLavender, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white24 : Colors.black26, size: 16),
          ],
        ),
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
            icon: Icon(
              Icons.arrow_back_ios_new, 
              color: isDark ? Colors.white70 : Colors.black87, 
              size: 20
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Sanctuary",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontSize: 18, 
              fontWeight: FontWeight.w600
            ),
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
        style: const TextStyle(
          color: AppColors.accentPurple, 
          fontSize: 12, 
          letterSpacing: 1.5, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(26)
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black45, 
                    fontSize: 13
                  )
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentLavender,
            activeTrackColor: AppColors.accentLavender.withAlpha(77), // 0.3 * 255 = 76.5 -> 77
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, bool isDark, {VoidCallback? onTap, bool isLogout = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(26)
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isLogout ? Colors.redAccent : (isDark ? Colors.white54 : Colors.black45), 
              size: 22
            ),
            const SizedBox(width: 20),
            Text(
              title, 
              style: TextStyle(
                color: isLogout ? Colors.redAccent : (isDark ? Colors.white : Colors.black87), 
                fontWeight: FontWeight.w500, 
                fontSize: 16
              )
            ),
            const Spacer(),
            if (!isLogout)
              Icon(
                Icons.arrow_forward_ios, 
                color: isDark ? Colors.white24 : Colors.black26, 
                size: 16
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(bool isDark) {
    final textColor = isDark ? Colors.white24 : Colors.black26;
    return Center(
      child: Column(
        children: [
          Text("Sanctuary v1.0.0", style: TextStyle(color: textColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text("Made with peace & code", style: TextStyle(color: textColor, fontSize: 10)),
        ],
      ),
    );
  }
}
