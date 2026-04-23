import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import 'progress.dart';
import 'add_task.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildTag(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accentLavender),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.mainBackground,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  const Text("Good Morning,", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600)),
                  const Text("Ahmad 👋", style: TextStyle(fontSize: 32, color: AppColors.accentLavender, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Your sanctuary is ready for the day ahead.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 30),

                  _buildProgressCard(),
                  const SizedBox(height: 30),

                  _sectionHeader("SUNRISE", "Morning Rituals", "Active Now", Icons.wb_sunny_outlined),
                  const SizedBox(height: 15),
                  _ritual("Vedic Meditation", "20 Minutes • Quiet Room", Icons.self_improvement),
                  _ritual("Hydration Ritual", "500ml Lemon Water", Icons.opacity),
                  const SizedBox(height: 30),

                  _sectionHeader("ZENITH", "Afternoon", null, Icons.wb_twilight),
                  const SizedBox(height: 15),
                  _buildTaskItem("COMING UP", "Deep Focus Work", AppColors.accentPink),
                  _buildTaskItem("14:00", "Power Nap", AppColors.cardBorder),
                  const SizedBox(height: 15),
                  _buildViewAllButton(),
                  const SizedBox(height: 30),

                  _sectionHeader("DUSK", "Evening Ritual", null, Icons.nightlight_round),
                  const SizedBox(height: 15),
                  _buildEveningCard(),
                  const SizedBox(height: 30),

                  _buildJourneyTeaser(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Positioned(bottom: 20, left: 20, right: 20, child: _customBottomNavBar(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: const [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
          SizedBox(width: 12),
          Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ]),
        const Icon(Icons.settings, color: Colors.white70)
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(height: 65, width: 65, child: CircularProgressIndicator(value: 0.7, strokeWidth: 8, color: AppColors.accentLavender, backgroundColor: Colors.white.withValues(alpha: 0.05))),
            const Text("70%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text("Today's Flow", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("7 of 10 rituals completed", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ])
        ],
      ),
    );
  }

  Widget _sectionHeader(String tag, String title, String? status, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTag(tag, icon),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
        if (status != null)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
              child: Text(status, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500))
          ),
      ],
    );
  }

  Widget _ritual(String title, String subtitle, IconData ritualIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.cardFill,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.cardBorder)
      ),
      child: Row(children: [
        const Icon(Icons.check_box_outline_blank, color: Colors.white30),
        const SizedBox(width: 15),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ]),
        ),
        Icon(ritualIcon, color: Colors.white30, size: 20),
      ]),
    );
  }

  Widget _buildTaskItem(String label, String task, Color indicatorColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(color: indicatorColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(task, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ])
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.cardBorder)),
      child: const Center(child: Text("View All 4 Tasks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildEveningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1511289081-d06eda4c6445?q=80&w=400"),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Prepare your body for restorative sleep\nwith gentle stretches and digital detox.", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          Row(children: [
            _circularBadge("1/3", Colors.blueAccent),
            const SizedBox(width: 8),
            _circularBadge("2/3", AppColors.accentPurple),
          ]),
          const SizedBox(height: 15),
          const Text("STARTING IN 8 HOURS", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _circularBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.6)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  Widget _buildJourneyTeaser() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("The Journey", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(40), border: Border.all(color: AppColors.cardBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text("CONSISTENCY STREAK", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("12 Days", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text("You've maintained your morning meditation for 12 days straight. This is 4 days more than your previous average.", style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          Center(
            child: Column(children: [
              const Icon(Icons.auto_graph, color: AppColors.accentLavender, size: 30),
              const SizedBox(height: 8),
              const Text("Growth Insights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text("Tap to analyze patterns", style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          )
        ],
      ),
    );
  }

  Widget _customBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF15182d).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Sanctuary", true, () {}),
          _navItem(Icons.add, "Add", false, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskScreen()))),
          _navItem(Icons.show_chart, "Journey", false, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JourneyScreen()))),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: isActive ? BoxDecoration(color: AppColors.accentLavender.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(30)) : null,
        child: Row(children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 24),
          if (isActive) const SizedBox(width: 8),
          if (isActive) Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
