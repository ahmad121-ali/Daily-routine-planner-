import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

// --- Data Models ---
class Ritual {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;

  Ritual({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isCompleted = false,
  });
}

class Task {
  final String label;
  final String title;
  final Color indicatorColor;

  Task({
    required this.label,
    required this.title,
    required this.indicatorColor,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Ritual> morningRituals = [
    Ritual(title: "Vedic Meditation", subtitle: "20 Minutes • Quiet Room", icon: Icons.self_improvement, isCompleted: true),
    Ritual(title: "Hydration Ritual", subtitle: "500ml Lemon Water", icon: Icons.opacity, isCompleted: false),
    Ritual(title: "Deep Breathing", subtitle: "5 Minutes • Balcony", icon: Icons.air, isCompleted: true),
  ];

  final List<Task> upcomingTasks = [
    Task(label: "COMING UP", title: "Deep Focus Work", indicatorColor: AppColors.accentPink),
    Task(label: "14:00", title: "Power Nap", indicatorColor: AppColors.cardBorder),
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

  double get _completionRate {
    if (morningRituals.isEmpty) return 0.0;
    int completed = morningRituals.where((r) => r.isCompleted).length;
    return completed / morningRituals.length;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    String formattedDate = "${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}";

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildHeader(context, formattedDate),
                      const SizedBox(height: 30),
                      Text("Good Morning,", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w300, fontSize: 32)),
                      Text("Ahmad 👋", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.accentLavender, fontSize: 32)),
                      const SizedBox(height: 10),
                      const Text("Your sanctuary is ready for the day ahead.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 30),
                      _buildGlassCard(_buildProgressCard()),
                      const SizedBox(height: 30),
                      _sectionHeader("SUNRISE", "Morning Rituals", "Active Now", Icons.wb_sunny_outlined),
                      const SizedBox(height: 15),
                      ...morningRituals.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildGlassCard(_ritualItem(r)),
                      )),
                      const SizedBox(height: 30),
                      _sectionHeader("ZENITH", "Afternoon", null, Icons.wb_twilight),
                      const SizedBox(height: 15),
                      ...upcomingTasks.map((t) => _buildTaskItem(t)),
                      const SizedBox(height: 15),
                      _buildViewAllButton(context),
                      const SizedBox(height: 30),
                      _sectionHeader("DUSK", "Evening Ritual", null, Icons.nightlight_round),
                      const SizedBox(height: 15),
                      _buildEveningCard(),
                      const SizedBox(height: 30),
                      _buildJourneyTeaser(context),
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
  }

  Widget _buildGlassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            child: const Hero(
              tag: 'profile-pic',
              child: CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              Text(date, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ]),
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

  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(
              height: 65, width: 65, 
              child: CircularProgressIndicator(
                value: _completionRate, 
                strokeWidth: 8, 
                color: AppColors.accentLavender, 
                backgroundColor: Colors.white.withValues(alpha: 0.05)
              )
            ),
            Text("${(_completionRate * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Today's Flow", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("${morningRituals.where((r) => r.isCompleted).length} of ${morningRituals.length} rituals completed", style: const TextStyle(color: Colors.white54, fontSize: 14)),
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
          Row(children: [
            Icon(icon, size: 14, color: AppColors.accentLavender),
            const SizedBox(width: 4),
            Text(tag, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54)),
          ]),
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

  Widget _ritualItem(Ritual ritual) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        Icon(
          ritual.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, 
          color: ritual.isCompleted ? AppColors.accentLavender : Colors.white30
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ritual.title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: ritual.isCompleted ? TextDecoration.lineThrough : null)),
            Text(ritual.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ]),
        ),
        Icon(ritual.icon, color: Colors.white30, size: 20),
      ]),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(color: task.indicatorColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ])
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/task-list'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.cardBorder)),
        child: const Center(child: Text("View All Rituals", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildEveningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), 
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1532033375034-a29004f7627a?q=80&w=400"),
          fit: BoxFit.cover, 
          opacity: 0.3
        )
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

  Widget _buildJourneyTeaser(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.cardBorder)),
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
          const Text("You've maintained your morning meditation for 12 days straight.", style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/insights'),
            child: Center(
              child: Column(children: [
                const Icon(Icons.auto_graph, color: AppColors.accentLavender, size: 30),
                const SizedBox(height: 8),
                const Text("Growth Insights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text("Tap to analyze patterns", style: TextStyle(color: Colors.white38, fontSize: 12)),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
