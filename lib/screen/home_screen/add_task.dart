import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool isReminderEnabled = true;
  String selectedFocus = "Deep Work";

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "New Intention",
                        style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Define your rhythm for the day ahead.",
                        style: TextStyle(color: Colors.white54, fontSize: 18),
                      ),
                      const SizedBox(height: 40),

                      _sectionLabel("INTENTION TITLE"),
                      _buildTitleInput(),

                      const SizedBox(height: 35),
                      _sectionLabel("TEMPORAL RHYTHM"),
                      _buildRhythmCard("Dawn", "06:00 - 10:00", Icons.wb_sunny_rounded, Colors.orangeAccent),
                      _buildRhythmCard("Zenith", "10:00 - 18:00", Icons.light_mode_rounded, AppColors.accentLavender, isRecommended: true),
                      _buildRhythmCard("Dusk", "18:00 - 00:00", Icons.nightlight_round, Colors.indigoAccent),

                      const SizedBox(height: 35),
                      _sectionLabel("FOCUS LEVEL"),
                      _buildFocusSelector(),

                      const SizedBox(height: 35),
                      _buildReminderToggle(),

                      const SizedBox(height: 40),
                      _buildCreateButton(),
                      const SizedBox(height: 100), // Space for bottom nav
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
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
              ),
              SizedBox(width: 12),
              Text(
                "Sanctuary",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Icon(Icons.settings, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "What are we focusing on?",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 16),
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 22),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRhythmCard(String title, String time, IconData icon, Color iconColor, {bool isRecommended = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isRecommended ? AppColors.accentLavender.withValues(alpha: 0.2) : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.white38, fontSize: 14)),
              ],
            ),
          ),
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentLavender.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentLavender.withValues(alpha: 0.2)),
              ),
              child: const Text("RECOMMENDED", style: TextStyle(color: AppColors.accentLavender, fontSize: 10, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  Widget _buildFocusSelector() {
    final levels = ["Soft", "Deep Work", "Flow"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: levels.map((level) {
        final isSelected = selectedFocus == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFocus = level),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryButtonGradient : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))] : [],
              ),
              child: Center(
                child: Text(
                  level,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Reminder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  "Notifications will be delivered in a gentle chime to maintain your sanctuary's peace.",
                  style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          Switch(
            value: isReminderEnabled,
            onChanged: (v) => setState(() => isReminderEnabled = v),
            activeThumbColor: AppColors.accentLavender,
            activeTrackColor: AppColors.accentLavender.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: AppColors.accentLavender.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Create Task", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(width: 12),
            Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}
