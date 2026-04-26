import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.mainBackground)),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Growth Insights", 
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text("Understand your flow patterns.", style: TextStyle(color: Colors.white54, fontSize: 18)),
                        const SizedBox(height: 40),

                        _buildMainStat(),
                        const SizedBox(height: 30),

                        const Text(
                          "WEEKLY OVERVIEW", 
                          style: TextStyle(color: AppColors.accentLavender, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildWeeklyChart(),

                        const SizedBox(height: 30),
                        _buildInsightCard("Deep Focus", "Your focus is 20% higher in the mornings. Consider moving complex tasks to 'Dawn'.", Icons.psychology_outlined),
                        _buildInsightCard("Consistency", "You've hit your 'Flow State' goal for 5 days straight. You're building a strong habit.", Icons.auto_graph_outlined),
                        const SizedBox(height: 40),
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Hero(
                tag: 'profile-pic',
                child: CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
              ),
              const SizedBox(width: 12),
              const Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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

  Widget _buildMainStat() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("AVG. FLOW RATE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("84%", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 50),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(0.6), _bar(0.8), _bar(1.0), _bar(0.7), _bar(0.9), _bar(0.5), _bar(0.85),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(double factor) {
    return Container(
      width: 20,
      height: 120 * factor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.accentLavender, AppColors.accentLavender.withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildInsightCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPink, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
