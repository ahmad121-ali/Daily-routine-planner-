import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

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

  final List<DailyMomentum> weeklyData = [
    DailyMomentum(day: "MON", value: 0.4),
    DailyMomentum(day: "TUE", value: 0.9),
    DailyMomentum(day: "WED", value: 0.7, isActive: true),
    DailyMomentum(day: "THU", value: 0.3),
    DailyMomentum(day: "FRI", value: 0.6),
    DailyMomentum(day: "SAT", value: 0.5),
    DailyMomentum(day: "SUN", value: 0.8),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.mainBackground)),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
              backgroundColor: const Color(0xFF1A1F36),
              color: AppColors.accentLavender,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      const SizedBox(height: 20),
                      _buildFlowProgress(),
                      const SizedBox(height: 40),
                      Text("You're flowing beautifully\ntoday.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, height: 1.2)),
                      const SizedBox(height: 15),
                      const Text("Your morning ritual is almost complete.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 40),
                      _buildWeeklyMomentum(),
                      const SizedBox(height: 40),
                      _buildMilestoneBadges(context),
                      const SizedBox(height: 120),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Hero(
                tag: 'profile-pic',
                child: CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
              ),
              SizedBox(width: 12),
              Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white70),
            offset: const Offset(0, 50),
            color: const Color(0xFF1A1F36),
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
              _buildPopupItem("edit", "Edit", Icons.edit),
              _buildPopupItem("settings", "Settings", Icons.settings_suggest),
              const PopupMenuDivider(height: 1),
              _buildPopupItem("logout", "Logout", Icons.logout, isDestructive: true),
            ],
          )
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String text, IconData icon, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70, size: 20),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFlowProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 210, height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.accentLavender.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 5)]
          ),
        ),
        SizedBox(
          width: 200, height: 200,
          child: CircularProgressIndicator(
            value: 0.75,
            strokeWidth: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            strokeCap: StrokeCap.round,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentLavender),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: const [
          Text("75%", style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
          Text("Flow State", style: TextStyle(color: Colors.white70, fontSize: 16)),
        ])
      ],
    );
  }

  Widget _buildWeeklyMomentum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Weekly Momentum", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text("View Trends", style: TextStyle(color: Colors.white38))),
          ],
        ),
        const SizedBox(height: 15),
        _buildGlassContainer(
          height: 160,
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyData.map((d) => _bar(d)).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildGlassContainer({required Widget child, double? height, required EdgeInsets padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _bar(DailyMomentum data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 80, width: 28,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: data.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: data.isActive ? [BoxShadow(color: AppColors.accentLavender.withValues(alpha: 0.4), blurRadius: 10)] : null,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: data.isActive
                      ? [AppColors.accentPink, AppColors.accentPurple]
                      : [AppColors.accentLavender.withValues(alpha: 0.6), AppColors.accentLavender.withValues(alpha: 0.3)],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(data.day, style: TextStyle(color: data.isActive ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMilestoneBadges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Milestone Badges", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.85,
          children: [
            _badge("Morning Sage", "7-day streak", Icons.verified_user, const Color(0xFF3F4177)),
            _badge("Deep Flow", "100 mins", Icons.auto_awesome, const Color(0xFF6B2D8C)),
            _badge("Zen Master", "30-day flow", Icons.spa, const Color(0xFF2D6B8C)),
            _badge("Consistency", "Daily Ritual", Icons.repeat, const Color(0xFF8C2D4A)),
            _badge("Mindfulness", "50 Sessions", Icons.self_improvement, const Color(0xFF4A8C2D)),
            _badge("Peak Flow", "Top 1% Today", Icons.trending_up, const Color(0xFF8C7A2D)),
          ],
        ),
      ],
    );
  }

  Widget _badge(String title, String sub, IconData icon, Color bgColor) {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor.withValues(alpha: 0.5),
              boxShadow: [BoxShadow(color: bgColor.withValues(alpha: 0.3), blurRadius: 15)]
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
