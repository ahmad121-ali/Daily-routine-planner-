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
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTask() async {
    if (_titleController.text.isEmpty) {
      _showFeedback("Please enter a title.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isLoading = false);
      _showFeedback("Intention set successfully.");
      _titleController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: isError ? Colors.redAccent.withValues(alpha: 0.9) : AppColors.accentPurple.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text("New Intention", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36, fontWeight: FontWeight.bold)),
                        const Text("Define your rhythm for the day ahead.", style: TextStyle(color: Colors.white54, fontSize: 18)),
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
                        const SizedBox(height: 140),
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: const TextStyle(color: AppColors.accentLavender, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      enabled: !_isLoading,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "What are we focusing on?",
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: AppColors.cardFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.cardBorder)),
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: 0.15)),
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
            onTap: _isLoading ? null : () => setState(() => selectedFocus = level),
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
                child: Text(level, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.cardBorder)),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reminder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text("Notifications will be delivered in a gentle chime.", style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          Switch(
            value: isReminderEnabled,
            onChanged: _isLoading ? null : (v) => setState(() => isReminderEnabled = v),
            activeThumbColor: AppColors.accentLavender,
            activeTrackColor: AppColors.accentLavender.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _handleCreateTask,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isLoading ? null : AppColors.primaryButtonGradient,
            color: _isLoading ? AppColors.cardFill : null,
            borderRadius: BorderRadius.circular(30),
            boxShadow: _isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.accentLavender.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
          ),
          child: Container(
            height: 58,
            width: double.infinity,
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Set Intention",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.auto_awesome_outlined,
                          color: Colors.white.withValues(alpha: 0.9), size: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
