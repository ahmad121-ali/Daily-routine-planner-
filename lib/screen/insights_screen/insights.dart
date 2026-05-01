import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import '../../services/ritual_service.dart';
import '../../services/theme_service.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ritualService = RitualService();
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: Listenable.merge([ritualService, themeService]),
      builder: (context, _) {
        final isDark = themeService.isDarkMode;
        final rituals = ritualService.allRituals;
        final completedCount = rituals.where((r) => r.isCompleted).length;
        final flowRate = rituals.isEmpty ? 0 : (completedCount / rituals.length * 100).toInt();
        
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white54 : Colors.black54;

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
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Growth Insights", 
                              style: TextStyle(
                                fontSize: 36, 
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Understand your flow patterns.", 
                              style: TextStyle(color: subTextColor, fontSize: 18)
                            ),
                            const SizedBox(height: 40),

                            _buildMainStat(flowRate),
                            const SizedBox(height: 30),

                            const Text(
                              "WEEKLY OVERVIEW", 
                              style: TextStyle(
                                color: AppColors.accentPurple, 
                                fontSize: 12, 
                                letterSpacing: 1.5, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildWeeklyChart(isDark, flowRate / 100),

                            const SizedBox(height: 30),
                            _buildInsightCard(
                              "Daily Flow", 
                              "You have completed $completedCount of ${rituals.length} rituals today. ${flowRate >= 80 ? 'Exceptional performance!' : 'Keep pushing for that flow state.'}", 
                              Icons.auto_graph_outlined,
                              isDark
                            ),
                            _buildInsightCard(
                              "Category Focus", 
                              "Your most active category today is ${_getTopCategory(rituals)}. Use this momentum to balance your other rituals.", 
                              Icons.category_outlined,
                              isDark
                            ),
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
      },
    );
  }

  String _getTopCategory(List rituals) {
    if (rituals.isEmpty) return "None";
    Map<String, int> counts = {};
    for (var r in rituals) {
      String cat = r.category.toString().split('.').last;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key.toUpperCase();
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final iconColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
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
          const Icon(Icons.auto_awesome, color: AppColors.accentLavender, size: 20),
        ],
      ),
    );
  }

  Widget _buildMainStat(int flowRate) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withAlpha(77), // 0.3 * 255 = 76.5 -> 77
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TODAY'S FLOW RATE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("$flowRate%", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 50),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDark, double currentDayValue) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8), // 0.03 * 255 = 7.65 -> 8
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20) // 0.08 * 255 = 20.4 -> 20
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(0.6), _bar(0.8), _bar(0.4), _bar(0.7), _bar(0.9), _bar(0.5), _bar(currentDayValue.clamp(0.1, 1.0)),
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
          colors: [AppColors.accentLavender, AppColors.accentLavender.withAlpha(51)], // 0.2 * 255 = 51
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildInsightCard(String title, String desc, IconData icon, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white38 : Colors.black45;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13), // 0.05 * 255 = 12.75 -> 13
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(26) // 0.1 * 255 = 25.5 -> 26
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPink, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
