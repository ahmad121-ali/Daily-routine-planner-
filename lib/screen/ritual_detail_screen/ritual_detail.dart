import 'package:flutter/material.dart';
import '../../models/ritual.dart';
import '../../theme/linear_gradient.dart';
import '../../services/theme_service.dart';
import '../../services/ritual_service.dart';
import '../../widgets/timer_dialog.dart';

class RitualDetailScreen extends StatefulWidget {
  final Ritual ritual;

  const RitualDetailScreen({super.key, required this.ritual});

  @override
  State<RitualDetailScreen> createState() => _RitualDetailScreenState();
}

class _RitualDetailScreenState extends State<RitualDetailScreen> {
  final RitualService _ritualService = RitualService();

  void _handleAction() {
    if (widget.ritual.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ritual already completed for today.")),
      );
      return;
    }

    if (widget.ritual.isTimed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TimerDialog(
          ritual: widget.ritual,
          onComplete: () {
            _ritualService.toggleStatus(widget.ritual.id);
            if (mounted) setState(() {});
          },
        ),
      );
    } else {
      _ritualService.toggleStatus(widget.ritual.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sanctuary updated: Ritual complete.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ritualService,
      builder: (context, _) {
        final isDark = ThemeService().isDarkMode;
        final textColor = isDark ? Colors.white : Colors.black87;
        final isCompleted = widget.ritual.isCompleted;

        return Scaffold(
          body: Stack(
            children: [
              // Background
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
              
              // Image Header
              if (widget.ritual.imageUrl != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 350,
                  child: Hero(
                    tag: 'ritual-image-${widget.ritual.id}',
                    child: Image.network(
                      widget.ritual.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Gradient Overlay for Image
              if (widget.ritual.imageUrl != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(102), // 0.4 * 255 = 102
                          Colors.transparent,
                          isDark ? const Color(0xFF0A0E21) : Colors.white,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: widget.ritual.imageUrl != null ? Colors.white : textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    expandedHeight: widget.ritual.imageUrl != null ? 300 : 0,
                    flexibleSpace: const FlexibleSpaceBar(background: SizedBox()),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.ritual.title,
                                      style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      "Intensity", // Simplified to avoid unused widget.ritual.subtitle if needed, but the original used it.
                                      style: TextStyle(color: AppColors.accentPurple, fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      widget.ritual.subtitle,
                                      style: const TextStyle(color: AppColors.accentPurple, fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isCompleted ? AppColors.accentLavender : widget.ritual.color).withAlpha(51), // 0.2 * 255 = 51
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : widget.ritual.icon, 
                                  color: isCompleted ? AppColors.accentLavender : widget.ritual.color, 
                                  size: 30
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _buildInfoRow(Icons.access_time_rounded, "Time", widget.ritual.time, isDark),
                          const SizedBox(height: 15),
                          _buildInfoRow(Icons.bolt, "Focus", widget.ritual.focus.name.toUpperCase(), isDark),
                          const SizedBox(height: 15),
                          if (widget.ritual.isTimed)
                            _buildInfoRow(Icons.timer_outlined, "Duration", "${widget.ritual.durationMinutes} minutes", isDark),
                          
                          const SizedBox(height: 40),
                          if (widget.ritual.techniques != null && widget.ritual.techniques!.isNotEmpty) ...[
                            const Text(
                              "TECHNIQUES",
                              style: TextStyle(
                                color: AppColors.accentPurple, 
                                fontSize: 12, 
                                letterSpacing: 1.5, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 20),
                            for (var entry in widget.ritual.techniques!.asMap().entries)
                              _buildTechniqueStep(entry.key + 1, entry.value, isDark),
                          ],
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Action Button
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: _buildActionButton(widget.ritual, isDark, isCompleted),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    final subTextColor = isDark ? Colors.white54 : Colors.black54;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Icon(icon, color: AppColors.accentPurple, size: 20),
        const SizedBox(width: 12),
        Text("$label: ", style: TextStyle(color: subTextColor, fontSize: 16)),
        Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTechniqueStep(int step, String text, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? AppColors.cardFill : Colors.black.withAlpha(13); // 0.05 * 255 = 12.75 -> 13

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.cardBorder : Colors.black.withAlpha(13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentPurple,
              shape: BoxShape.circle,
            ),
            child: Text(
              step.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Ritual ritual, bool isDark, bool isCompleted) {
    return ElevatedButton(
      onPressed: _handleAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted ? Colors.grey.shade800 : AppColors.accentPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isCompleted ? 0 : 10,
        shadowColor: AppColors.accentPurple.withAlpha(77), // 0.3 * 255 = 76.5 -> 77
      ),
      child: Text(
        isCompleted 
            ? "COMPLETED" 
            : (ritual.isTimed ? "START RITUAL" : "MARK AS COMPLETE"),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
