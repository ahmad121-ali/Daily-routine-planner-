import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/linear_gradient.dart';
import '../../models/ritual.dart';
import '../../services/ritual_service.dart';
import '../../widgets/timer_dialog.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final RitualService _ritualService = RitualService();
  String selectedFilter = "All";
  String searchQuery = "";
  
  final List<String> filters = ["All", "Dawn", "Zenith", "Dusk"];

  @override
  void initState() {
    super.initState();
    _ritualService.addListener(_refresh);
  }

  @override
  void dispose() {
    _ritualService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<Ritual> get filteredRituals {
    return _ritualService.allRituals.where((r) {
      final matchesFilter = selectedFilter == "All" || 
                           r.period.name.toLowerCase() == selectedFilter.toLowerCase();
      final matchesSearch = r.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
                           r.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _handleRitualTap(Ritual ritual) {
    if (ritual.isTimed && !ritual.isCompleted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TimerDialog(
          ritual: ritual, 
          onComplete: () => _ritualService.toggleStatus(ritual.id),
        ),
      );
    } else if (!ritual.isCounter) {
      _ritualService.toggleStatus(ritual.id);
    }
  }

  void _showDeleteDialog(Ritual ritual) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1F36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Delete Ritual?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to remove '${ritual.title}' from your sanctuary?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                _ritualService.deleteRitual(ritual.id);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // To show background below bottom sheet
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.mainBackground)),
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
                      
                      if (filteredRituals.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredRituals.map((ritual) => _ritualItem(ritual)),
                      
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          Icon(Icons.search_off_rounded, color: Colors.white12, size: 80),
          SizedBox(height: 16),
          Text("No rituals found", style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Try a different period or search.", style: TextStyle(color: Colors.white24, fontSize: 13)),
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
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
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
                color: isSelected ? AppColors.accentLavender : Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withAlpha(26),
                ),
              ),
              child: Center(
                child: Text(
                  filters[index].toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                    letterSpacing: 1.0,
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
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const Hero(
                tag: 'profile-pic-list',
                child: CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
              ),
              const SizedBox(width: 12),
              const Text("Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.auto_awesome, color: AppColors.accentLavender, size: 20),
        ],
      ),
    );
  }

  Widget _ritualItem(Ritual ritual) {
    final color = ritual.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withAlpha(8),
            child: InkWell(
              onTap: () => _handleRitualTap(ritual),
              onLongPress: () => _showDeleteDialog(ritual),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ritual.isCompleted ? AppColors.accentLavender.withAlpha(26) : color.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ritual.isCompleted ? Icons.check : (ritual.isTimed ? Icons.timer_outlined : ritual.icon), 
                        color: ritual.isCompleted ? AppColors.accentLavender : color, 
                        size: 22
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ritual.title, 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 17, 
                              fontWeight: FontWeight.w700,
                              decoration: ritual.isCompleted ? TextDecoration.lineThrough : null,
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${ritual.time} • ${ritual.period.name.toUpperCase()}", 
                            style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                    ),
                    if (ritual.isCounter)
                      _buildCounterUI(ritual)
                    else
                      const Icon(
                        Icons.more_vert, 
                        color: Colors.white12, 
                        size: 18
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

  Widget _buildCounterUI(Ritual ritual) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _ritualService.decrementCounter(ritual.id),
          icon: const Icon(Icons.remove_circle_outline, color: Colors.white24, size: 20),
        ),
        Text(
          "${ritual.currentCount}/${ritual.goalCount}", 
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)
        ),
        IconButton(
          onPressed: () => _ritualService.incrementCounter(ritual.id),
          icon: Icon(Icons.add_circle_outline, color: AppColors.accentLavender.withAlpha(179), size: 20),
        ),
      ],
    );
  }
}
