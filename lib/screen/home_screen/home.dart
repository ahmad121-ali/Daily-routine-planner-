import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/linear_gradient.dart';
import '../../models/ritual.dart';
import '../../services/ritual_service.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';
import '../task_list_screen/task_list.dart';
import '../ritual_detail_screen/ritual_detail.dart';
import '../../widgets/timer_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final RitualService _ritualService = RitualService();
  final ThemeService _themeService = ThemeService();
  final AuthService _authService = AuthService();
  
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    _ritualService.addListener(_refresh);
    _themeService.addListener(_refresh);
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _authService.currentUser;
    if (user != null && !user.isAnonymous) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['fullName'] ?? "User";
        });
      }
    } else if (user != null && user.isAnonymous) {
      setState(() {
        _userName = "Guest";
      });
    }
  }

  @override
  void dispose() {
    _ritualService.removeListener(_refresh);
    _themeService.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _handleRitualTap(Ritual ritual) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RitualDetailScreen(ritual: ritual),
      ),
    );
  }

  void _handleAction(Ritual ritual) {
    if (ritual.isCompleted) {
      _ritualService.toggleStatus(ritual.id);
      return;
    }

    if (ritual.isTimed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TimerDialog(
          ritual: ritual,
          onComplete: () {
            _ritualService.toggleStatus(ritual.id);
          },
        ),
      );
    } else {
      _ritualService.toggleStatus(ritual.id);
    }
  }

  double get _completionRate {
    final rituals = _ritualService.allRituals;
    if (rituals.isEmpty) return 0.0;
    int completed = rituals.where((r) => r.isCompleted).length;
    return completed / rituals.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeService.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    final now = DateTime.now();
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    String formattedDate = "${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}";

    final allRituals = _ritualService.allRituals;
    final dawnRituals = allRituals.where((r) => r.period == RitualPeriod.dawn).toList();
    final zenithRituals = allRituals.where((r) => r.period == RitualPeriod.zenith).toList();
    final duskRituals = allRituals.where((r) => r.period == RitualPeriod.dusk).toList();

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
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchUserData();
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) setState(() {});
              },
              backgroundColor: isDark ? const Color(0xFF1A1F36) : Colors.white,
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
                      _buildHeader(context, formattedDate, isDark),
                      const SizedBox(height: 30),
                      Text("Good Morning,", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 32, color: textColor)),
                      Text("$_userName 👋", style: const TextStyle(color: AppColors.accentLavender, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Your sanctuary is ready for the day ahead.", style: TextStyle(color: subTextColor, fontSize: 16)),
                      const SizedBox(height: 30),
                      _buildGlassCard(_buildProgressCard(isDark), isDark),
                      
                      if (dawnRituals.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        _sectionHeader("SUNRISE", "Morning Rituals", "Active Now", Icons.wb_sunny_outlined, isDark),
                        const SizedBox(height: 15),
                        ...dawnRituals.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGlassCard(_ritualItem(r, isDark), isDark),
                        )),
                      ],
                      
                      if (zenithRituals.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        _sectionHeader("ZENITH", "Afternoon Flow", "Zenith", Icons.wb_twilight, isDark),
                        const SizedBox(height: 15),
                        ...zenithRituals.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGlassCard(_ritualItem(r, isDark), isDark),
                        )),
                      ],
                      
                      const SizedBox(height: 15),
                      _buildViewAllButton(context, isDark),
                      
                      if (duskRituals.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        _sectionHeader("DUSK", "Evening Rituals", "Tonight", Icons.nightlight_round, isDark),
                        const SizedBox(height: 15),
                        ...duskRituals.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGlassCard(_ritualItem(r, isDark), isDark),
                        )),
                      ],
                      
                      const SizedBox(height: 30),
                      _buildJourneyTeaser(context, isDark),
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

  Widget _buildGlassCard(Widget child, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(13)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String date, bool isDark) {
    final iconColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black87;

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
              Text("Sanctuary", style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w600)),
              Text(date, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ]),
        PopupMenuButton<String>(
          icon: Icon(Icons.settings, color: iconColor),
          offset: const Offset(0, 50),
          color: isDark ? const Color(0xFF1A1F36) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onSelected: (value) async {
            if (value == 'logout') {
              final navigator = Navigator.of(context);
              await _authService.signOut();
              navigator.pushReplacementNamed('/');
            } else if (value == 'edit') {
              Navigator.pushNamed(context, '/edit-profile');
            } else if (value == 'settings') {
              Navigator.pushNamed(context, '/settings');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: "edit", child: Text("Edit", style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
            PopupMenuItem(value: "settings", child: Text("Settings", style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem(value: "logout", child: Text("Logout", style: TextStyle(color: Colors.redAccent))),
          ],
        )
      ],
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final rituals = _ritualService.allRituals;
    final completedCount = rituals.where((r) => r.isCompleted).length;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

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
                backgroundColor: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13)
              )
            ),
            Text("${(_completionRate * 100).toInt()}%", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Today's Flow", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("$completedCount of ${rituals.length} rituals completed", style: TextStyle(color: subTextColor, fontSize: 14)),
          ])
        ],
      ),
    );
  }

  Widget _sectionHeader(String tag, String title, String? status, IconData icon, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 14, color: AppColors.accentLavender),
            const SizedBox(width: 4),
            Text(tag, style: TextStyle(color: subTextColor, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
        if (status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13), 
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(13))
            ),
            child: Text(status, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12, fontWeight: FontWeight.w500))
          ),
      ],
    );
  }

  Widget _ritualItem(Ritual ritual, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white38 : Colors.black38;

    return InkWell(
      onTap: () => _handleRitualTap(ritual),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          _buildLeadingIcon(ritual, isDark),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ritual.title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600, decoration: ritual.isCompleted ? TextDecoration.lineThrough : null)),
              Text(ritual.subtitle, style: TextStyle(color: subTextColor, fontSize: 13)),
            ]),
          ),
          if (ritual.isCounter) 
            _buildCounterControls(ritual, isDark) 
          else 
            _buildActionIcon(ritual, isDark),
        ]),
      ),
    );
  }

  Widget _buildLeadingIcon(Ritual ritual, bool isDark) {
    if (ritual.isCompleted) return const Icon(Icons.check_circle, color: AppColors.accentLavender);
    if (ritual.isTimed) return Icon(Icons.timer_outlined, color: isDark ? Colors.white30 : Colors.black26);
    return Icon(Icons.radio_button_unchecked, color: isDark ? Colors.white30 : Colors.black26);
  }

  Widget _buildActionIcon(Ritual ritual, bool isDark) {
    return IconButton(
      onPressed: () => _handleAction(ritual),
      icon: Icon(
        ritual.isCompleted 
            ? Icons.check_circle 
            : (ritual.isTimed ? Icons.play_circle_fill : Icons.check_circle_outline),
        color: AppColors.accentLavender.withAlpha(204), // 0.8 * 255 = 204
        size: 28,
      ),
    );
  }

  Widget _buildCounterControls(Ritual ritual, bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Row(
      children: [
        IconButton(
          onPressed: () => _ritualService.decrementCounter(ritual.id),
          icon: Icon(Icons.remove_circle_outline, color: isDark ? Colors.white24 : Colors.black26, size: 20),
        ),
        Text("${ritual.currentCount}/${ritual.goalCount}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        IconButton(
          onPressed: () => _ritualService.incrementCounter(ritual.id),
          icon: Icon(Icons.add_circle_outline, color: AppColors.accentLavender.withAlpha(179), size: 20),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          useSafeArea: true, 
          builder: (context) => const FractionallySizedBox(
            heightFactor: 1.0, 
            child: TaskListScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13), 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(13))
        ),
        child: Center(child: Text("View All Rituals", style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildJourneyTeaser(BuildContext context, bool isDark) {
    final rituals = _ritualService.allRituals;
    final completed = rituals.where((r) => r.isCompleted).length;
    final total = rituals.length;
    final unlockedMilestones = _ritualService.milestones.where((m) => m.isUnlocked).length;

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white38 : Colors.black45;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardFill : Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(13))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("The Journey", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardFill : Colors.black.withAlpha(13),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(13))
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("MILESTONES REACHED", style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("$unlockedMilestones Badges", style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),
          Text(
            "You've completed $completed of $total rituals today. ${completed == total && total > 0 ? 'Perfect flow achieved!' : 'Keep going to unlock more insights.'}",
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/insights'),
            child: Center(
              child: Column(children: [
                const Icon(Icons.auto_graph, color: AppColors.accentLavender, size: 30),
                const SizedBox(height: 8),
                Text("Growth Insights", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Text("Tap to analyze patterns", style: TextStyle(color: subTextColor, fontSize: 12)),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
