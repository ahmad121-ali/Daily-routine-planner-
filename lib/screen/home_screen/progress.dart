import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildFlowProgress(),
                      const SizedBox(height: 40),
                      const Text("You're flowing beautifully\ntoday.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 15),
                      const Text("Your morning ritual is almost complete.\nTake a breath and lean into the rhythm.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 40),
                      _buildWeeklyMomentum(),
                      const SizedBox(height: 40),
                      _buildMilestoneBadges(),
                      const SizedBox(height: 100), // Space for nav bar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
              SizedBox(width: 12),
              Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.settings, color: Colors.white70),
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
              boxShadow: [
                BoxShadow(color: AppColors.accentLavender.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 5)
              ]
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
        Container(
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppColors.cardFill,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.cardBorder)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(0.4, "MON"), _bar(0.9, "TUE"), _bar(0.7, "WED", active: true),
              _bar(0.3, "THU"), _bar(0.3, "FRI"), _bar(0.3, "SAT"), _bar(0.3, "SUN"),
            ],
          ),
        )
      ],
    );
  }

  Widget _bar(double heightFactor, String day, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 80, width: 28,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: active ? [BoxShadow(color: AppColors.accentLavender.withValues(alpha: 0.4), blurRadius: 10)] : null,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: active
                      ? [AppColors.accentPink, AppColors.accentPurple]
                      : [AppColors.accentLavender.withValues(alpha: 0.6), AppColors.accentLavender.withValues(alpha: 0.3)],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(day, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMilestoneBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Milestone Badges", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.85,
          children: [
            _badge("Morning Sage", "7-day streak\ncomplete", Icons.verified_user, const Color(0xFF3F4177)),
            _badge("Deep Flow", "100 mins of focus", Icons.auto_awesome, const Color(0xFF6B2D8C)),
            _badge("Momentum", "3 habits unlocked", Icons.bolt, const Color(0xFF1F1F1F)),
            _badge("Zen Master", "Keep going...", Icons.lock, const Color(0xFF1A1A1A), isLocked: true),
          ],
        ),
      ],
    );
  }

  Widget _badge(String title, String sub, IconData icon, Color bgColor, {bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.transparent : AppColors.cardFill,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isLocked ? AppColors.cardBorder : Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor.withValues(alpha: isLocked ? 0.2 : 0.5),
                boxShadow: isLocked ? [] : [BoxShadow(color: bgColor.withValues(alpha: 0.3), blurRadius: 15)]
            ),
            child: Icon(icon, color: isLocked ? Colors.white24 : Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: isLocked ? Colors.white38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
