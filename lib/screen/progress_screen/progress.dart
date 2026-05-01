import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import '../../services/theme_service.dart';
import '../../services/ritual_service.dart';

// --- Momentum Model ---
class DailyMomentum {
  final String day;
  final double value;
  final bool isActive;
  DailyMomentum({required this.day, required this.value, this.isActive = false});
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final RitualService _ritualService = RitualService();
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _completionRate {
    final rituals = _ritualService.allRituals;
    if (rituals.isEmpty) return 0.0;
    int completed = rituals.where((r) => r.isCompleted).length;
    return completed / rituals.length;
  }

  List<DailyMomentum> get _weeklyData {
    final now = DateTime.now();
    final days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    final currentDayIndex = (now.weekday - 1); // 0-6

    return List.generate(7, (index) {
      if (index == currentDayIndex) {
        return DailyMomentum(
          day: days[index], 
          value: _completionRate.clamp(0.1, 1.0), 
          isActive: true
        );
      }
      return DailyMomentum(
        day: days[index], 
        value: [0.4, 0.9, 0.7, 0.3, 0.6, 0.5, 0.8][index], 
        isActive: false
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_themeService, _ritualService]),
      builder: (context, _) {
        final isDark = _themeService.isDarkMode;
        final completion = _completionRate;
        final textColor = isDark ? Colors.white : Colors.black87;
        final milestones = _ritualService.milestones;

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
                child: RefreshIndicator(
                  onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
                  backgroundColor: isDark ? const Color(0xFF1A1F36) : Colors.white,
                  color: AppColors.accentLavender,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildAppBar(context, isDark),
                          const SizedBox(height: 20),
                          _buildFlowProgress(completion, isDark),
                          const SizedBox(height: 40),
                          Text(
                            completion >= 1.0 
                                ? "You've mastered\nyour day." 
                                : completion > 0.5 
                                    ? "You're flowing beautifully\ntoday." 
                                    : "Keep moving toward\nyour sanctuary.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28, 
                              height: 1.2, 
                              color: textColor, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 40),
                          _sectionLabel("WEEKLY MOMENTUM"),
                          _buildWeeklyMomentum(isDark),
                          const SizedBox(height: 40),
                          _sectionLabel("30-DAY CONSISTENCY"),
                          _buildActivityGrid(isDark),
                          const SizedBox(height: 40),
                          _sectionLabel("MILESTONE BADGES"),
                          _buildMilestoneBadges(milestones, isDark),
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          text, 
          style: const TextStyle(
            color: AppColors.accentPurple, 
            fontSize: 12, 
            letterSpacing: 1.5, 
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final iconColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Hero(
                tag: 'profile-pic',
                child: CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
              ),
              const SizedBox(width: 12),
              Text(
                "Sanctuary", 
                style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w600)
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: iconColor),
            offset: const Offset(0, 50),
            color: isDark ? const Color(0xFF1A1F36) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/');
              } else if (value == 'edit') {
                Navigator.pushNamed(context, '/edit-profile');
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              }
            },
            itemBuilder: (context) => [
              _buildPopupItem("edit", "Edit", Icons.edit, isDark),
              _buildPopupItem("settings", "Settings", Icons.settings_suggest, isDark),
              const PopupMenuDivider(height: 1),
              _buildPopupItem("logout", "Logout", Icons.logout, isDark, isDestructive: true),
            ],
          )
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String text, IconData icon, bool isDark, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon, 
            color: isDestructive ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54), 
            size: 20
          ),
          const SizedBox(width: 10),
          Text(
            text, 
            style: TextStyle(color: isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black87))
          ),
        ],
      ),
    );
  }

  Widget _buildFlowProgress(double completion, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 210, height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentLavender.withAlpha(isDark ? 26 : 13), // 0.1 * 255 = 25.5 -> 26, 0.05 * 255 = 12.75 -> 13
                blurRadius: 40, 
                spreadRadius: 5
              )
            ]
          ),
        ),
        SizedBox(
          width: 200, height: 200,
          child: CircularProgressIndicator(
            value: completion,
            strokeWidth: 12,
            backgroundColor: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13),
            strokeCap: StrokeCap.round,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentLavender),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "${(completion * 100).toInt()}%", 
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontSize: 56, 
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            "Flow State", 
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54, 
              fontSize: 16
            )
          ),
        ])
      ],
    );
  }

  Widget _buildWeeklyMomentum(bool isDark) {
    return _buildGlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _weeklyData.map((d) => _bar(d, isDark)).toList(),
      ),
    );
  }

  Widget _buildActivityGrid(bool isDark) {
    return _buildGlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final isToday = index == 22; 
              final opacity = isToday 
                  ? (_completionRate.clamp(0.2, 1.0))
                  : (index % 5 == 0) ? 0.8 : (index % 3 == 0) ? 0.4 : 0.1;
              
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLavender.withAlpha((opacity * 255).toInt()),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Less Active", 
                style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)
              ),
              const Text(
                "Peak Flow", 
                style: TextStyle(color: AppColors.accentLavender, fontSize: 10, fontWeight: FontWeight.bold)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, double? height, required EdgeInsets padding, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8), // 0.03 * 255 = 7.65 -> 8
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13) // 0.05 * 255 = 12.75 -> 13
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _bar(DailyMomentum data, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 80, width: 28,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13), 
            borderRadius: BorderRadius.circular(15)
          ),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: data.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: data.isActive 
                    ? [BoxShadow(color: AppColors.accentLavender.withAlpha(102), blurRadius: 10)] // 0.4 * 255 = 102
                    : null,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: data.isActive
                      ? [AppColors.accentPink, AppColors.accentPurple]
                      : [
                          AppColors.accentLavender.withAlpha(153), // 0.6 * 255 = 153
                          AppColors.accentLavender.withAlpha(77)   // 0.3 * 255 = 76.5 -> 77
                        ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data.day, 
          style: TextStyle(
            color: data.isActive 
                ? (isDark ? Colors.white : Colors.black87) 
                : (isDark ? Colors.white38 : Colors.black38), 
            fontSize: 10, 
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }

  Widget _buildMilestoneBadges(List<Milestone> milestones, bool isDark) {
    return GridView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        mainAxisSpacing: 20, 
        crossAxisSpacing: 20, 
        childAspectRatio: 0.85
      ),
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        return _badge(milestone, isDark);
      },
    );
  }

  Widget _badge(Milestone milestone, bool isDark) {
    return _buildGlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: milestone.isUnlocked 
                  ? milestone.color.withAlpha(128) // 0.5 * 255 = 127.5 -> 128
                  : Colors.grey.withAlpha(51),    // 0.2 * 255 = 51
              boxShadow: milestone.isUnlocked 
                  ? [BoxShadow(color: milestone.color.withAlpha(77), blurRadius: 15)] // 0.3 * 255 = 76.5 -> 77
                  : null
            ),
            child: Icon(
              milestone.isUnlocked ? milestone.icon : Icons.lock_outline, 
              color: milestone.isUnlocked ? Colors.white : Colors.white24, 
              size: 28
            ),
          ),
          const SizedBox(height: 16),
          Text(
            milestone.title, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              color: milestone.isUnlocked 
                  ? (isDark ? Colors.white : Colors.black87) 
                  : (isDark ? Colors.white24 : Colors.black26), 
              fontWeight: FontWeight.bold, 
              fontSize: 15
            )
          ),
          Text(
            milestone.isUnlocked ? milestone.description : "Locked",
            textAlign: TextAlign.center, 
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black45, 
              fontSize: 12
            )
          ),
        ],
      ),
    );
  }
}
