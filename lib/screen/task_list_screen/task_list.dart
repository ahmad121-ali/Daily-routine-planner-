import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "Flow", "Deep", "Soft"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(decoration: const BoxDecoration(gradient: AppColors.mainBackground)),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 20),
                      _buildHeaderSection(),
                      const SizedBox(height: 30),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildFilterChips(),
                      const SizedBox(height: 30),
                      
                      // Ritual Items (Backend will map these later)
                      _ritualItem("Vedic Meditation", "06:30 AM", "Flow", Icons.self_improvement, AppColors.accentLavender),
                      _ritualItem("Deep Focus Work", "09:00 AM", "Deep", Icons.computer, AppColors.accentPurple),
                      _ritualItem("Power Nap", "02:00 PM", "Soft", Icons.hotel, Colors.blueAccent),
                      _ritualItem("Evening Yoga", "07:30 PM", "Soft", Icons.self_improvement, AppColors.accentPink),
                      _ritualItem("Gratitude Journal", "10:00 PM", "Flow", Icons.edit_note, Colors.tealAccent),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Rituals", 
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 40, 
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Manage your sanctuary's rhythm.", 
          style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 0.2),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search your rituals...",
              hintStyle: TextStyle(color: Colors.white24, fontSize: 15),
              prefixIcon: Icon(Icons.search, color: Colors.white38, size: 22),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == filters[index];
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filters[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentLavender : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
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
              if (value == 'logout') Navigator.pushReplacementNamed(context, '/');
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

  Widget _ritualItem(String title, String time, String focus, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withValues(alpha: 0.03),
            child: InkWell(
              onTap: () {}, // For backend details
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            focus.toUpperCase(), 
                            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
