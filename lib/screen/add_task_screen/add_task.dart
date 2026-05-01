import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import '../../models/ritual.dart';
import '../../services/ritual_service.dart';
import '../../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final RitualService _ritualService = RitualService();
  final TaskService _taskService = TaskService(); 
  
  bool isReminderEnabled = true;
  String selectedFocus = "Flow";
  String selectedCategory = "Mind";
  String? selectedSubCategory; 
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> categories = [
    {"name": "Mind", "icon": Icons.psychology, "color": AppColors.accentLavender},
    {"name": "Body", "icon": Icons.fitness_center, "color": Colors.orangeAccent},
    {"name": "Work", "icon": Icons.work, "color": AppColors.accentPurple},
    {"name": "Soul", "icon": Icons.favorite, "color": Colors.tealAccent},
  ];

  final Map<String, List<String>> recommendations = {
    "Mind": ["Vedic Meditation", "Journaling", "Reading", "Deep Breathing"],
    "Body": ["Chest Workout", "Back Workout", "Leg Workout", "Shoulder Workout", "Core Workout"],
    "Work": ["Deep Focus", "Email Batching", "Planning", "Research"],
    "Soul": ["Gratitude", "Prayer", "Nature Walk", "Listening to Music"],
  };

  final Map<String, List<Map<String, dynamic>>> gymExerciseDetails = {
    "Chest Workout": [
      {"name": "Bench Press", "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=500", "techniques": ["Lie flat on the bench", "Grip bar wide", "Lower to chest", "Push up"]},
      {"name": "Incline Press", "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=500", "techniques": ["Adjust bench to 30-45 degrees", "Focus on upper chest", "Press weights up", "Control descent"]},
      {"name": "Chest Flys", "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500", "techniques": ["Wide arc motion", "Squeeze chest", "Control weight", "Keep elbows slightly bent"]},
    ],
    "Back Workout": [
      {"name": "Pull Ups", "image": "https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?q=80&w=500", "techniques": ["Wide grip", "Pull chin above bar", "Squeeze shoulder blades", "Full extension"]},
      {"name": "Deadlift", "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500", "techniques": ["Feet hip-width", "Flat back", "Drive through heels", "Chest up"]},
    ],
    "Leg Workout": [
      {"name": "Squats", "image": "https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=500", "techniques": ["Shoulder width stance", "Hips below knees", "Weight on heels", "Drive up"]},
    ],
    "Shoulder Workout": [
      {"name": "Overhead Press", "image": "https://images.unsplash.com/photo-1541534741688-6078c64b52d2?q=80&w=500", "techniques": ["Core tight", "Press to ceiling", "Full lockout", "Controlled descent"]},
    ],
    "Core Workout": [
      {"name": "Plank", "image": "https://images.unsplash.com/photo-1566241142559-40e1bfc26ebc?q=80&w=500", "techniques": ["Elbows under shoulders", "Straight body line", "Squeeze glutes", "Hold tight"]},
    ],
  };

  final List<Map<String, String>> focusLevels = [
    {"name": "Soft", "desc": "Light & Easy", "duration": "0"},
    {"name": "Flow", "desc": "Creative state", "duration": "20"},
    {"name": "Deep", "desc": "Max intensity", "duration": "90"},
  ];

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
    
    try {
      if (!mounted) return;
      final timeStr = selectedTime.format(context);
      final period = _calculatePeriod(selectedTime);
      final focusData = focusLevels.firstWhere((f) => f['name'] == selectedFocus);
      final bool isTimed = selectedFocus != "Soft";
      final int? duration = int.parse(focusData['duration']!) > 0 ? int.parse(focusData['duration']!) : null;

      String? imageUrl;
      List<String>? techniques;

      if (selectedCategory == "Body" && selectedSubCategory != null) {
        final List<Map<String, dynamic>>? categoryDetails = gymExerciseDetails[selectedSubCategory!];
        if (categoryDetails != null) {
          final detail = categoryDetails.firstWhere(
            (e) => e['name'] == _titleController.text,
            orElse: () => <String, dynamic>{},
          );
          if (detail.isNotEmpty) {
            imageUrl = detail['image'];
            techniques = List<String>.from(detail['techniques'] ?? []);
          }
        }
      }

      // 1. Save to Firebase (Cloud) with ALL detailed information
      await _taskService.addTask(
        title: _titleController.text,
        category: selectedCategory,
        time: timeStr,
        focus: selectedFocus,
        period: period.name,
        isTimed: isTimed,
        duration: duration,
        imageUrl: imageUrl,
        techniques: techniques,
      );

      // 2. Prepare Local Logic for immediate UI update
      final categoryData = categories.firstWhere((c) => c['name'] == selectedCategory);
      
      final newRitual = Ritual(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        subtitle: "$selectedFocus Intensity",
        time: timeStr,
        category: RitualCategory.values.firstWhere((e) => e.name == selectedCategory.toLowerCase()),
        focus: RitualFocus.values.firstWhere((e) => e.name == selectedFocus.toLowerCase()),
        period: period,
        icon: categoryData['icon'],
        color: categoryData['color'],
        isTimed: isTimed,
        durationMinutes: duration,
        imageUrl: imageUrl,
        techniques: techniques,
      );

      _ritualService.addRitual(newRitual);

      if (mounted) {
        setState(() => _isLoading = false);
        _showFeedback("Intention set and synced to cloud!");
        // After successfully creating a task, go back to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showFeedback("Error syncing: $e", isError: true);
      }
    }
  }

  RitualPeriod _calculatePeriod(TimeOfDay time) {
    if (time.hour >= 5 && time.hour < 12) return RitualPeriod.dawn;
    if (time.hour >= 12 && time.hour < 18) return RitualPeriod.zenith;
    return RitualPeriod.dusk;
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : AppColors.accentPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ));
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
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text("New Intention", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text("Define your rhythm for the day.", style: TextStyle(color: Colors.white54, fontSize: 18)),
                        const SizedBox(height: 40),

                        _sectionLabel("INTENTION TITLE"),
                        _buildTitleInput(),
                        const SizedBox(height: 12),
                        _buildRecommendations(),

                        const SizedBox(height: 35),
                        _sectionLabel("CATEGORY"),
                        _buildCategorySelector(),

                        const SizedBox(height: 35),
                        _sectionLabel("TEMPORAL RHYTHM"),
                        _buildTimePickerTrigger(),

                        const SizedBox(height: 35),
                        _sectionLabel("FOCUS LEVEL"),
                        _buildFocusSelector(),

                        const SizedBox(height: 40),
                        _buildCreateButton(),
                        const SizedBox(height: 120),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70), 
            onPressed: () => Navigator.pushReplacementNamed(context, '/home')
          ),
          const Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(color: AppColors.accentLavender, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: AppColors.cardFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        hintText: "What is your intention?", hintStyle: const TextStyle(color: Colors.white24),
      ),
    );
  }

  Widget _buildRecommendations() {
    List<String> suggestions;
    final categoryColor = categories.firstWhere((c) => c['name'] == selectedCategory)['color'] as Color;

    if (selectedCategory == "Body" && selectedSubCategory != null) {
      suggestions = gymExerciseDetails[selectedSubCategory!]?.map((e) => e['name'] as String).toList() ?? [];
    } else {
      suggestions = recommendations[selectedCategory] ?? [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedSubCategory != null && selectedCategory == "Body")
          TextButton.icon(
            onPressed: () => setState(() => selectedSubCategory = null),
            icon: const Icon(Icons.arrow_back, size: 14, color: Colors.orangeAccent),
            label: const Text("Back to Body Groups", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
          ),
        Wrap(
          spacing: 8,
          children: suggestions.map((text) => ActionChip(
            label: Text(text),
            backgroundColor: categoryColor.withValues(alpha: 0.1),
            onPressed: () {
              if (selectedCategory == "Body" && selectedSubCategory == null) {
                setState(() => selectedSubCategory = text);
              } else {
                setState(() => _titleController.text = text);
              }
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        final isSelected = selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () => setState(() { selectedCategory = cat['name']; selectedSubCategory = null; }),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? (cat['color'] as Color).withValues(alpha: 0.2) : AppColors.cardFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? (cat['color'] as Color) : AppColors.cardBorder),
                ),
                child: Icon(cat['icon'], color: isSelected ? (cat['color'] as Color) : Colors.white38),
              ),
              const SizedBox(height: 8),
              Text(cat['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePickerTrigger() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: selectedTime);
        if (picked != null) setState(() => selectedTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Icon(Icons.access_time, color: AppColors.accentLavender),
          const SizedBox(width: 15),
          Text(selectedTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildFocusSelector() {
    return Row(
      children: focusLevels.map((level) {
        final isSelected = selectedFocus == level['name'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFocus = level['name']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryButtonGradient : null,
                color: isSelected ? null : AppColors.cardFill,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Text(level['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity, height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
        ),
        onPressed: _isLoading ? null : _handleCreateTask,
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Set Intention", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
