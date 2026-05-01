import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ritual.dart';
import '../theme/linear_gradient.dart';

class Milestone {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  Milestone({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class RitualService extends ChangeNotifier {
  static final RitualService _instance = RitualService._internal();
  factory RitualService() => _instance;
  RitualService._internal() {
    _init();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Ritual> _rituals = [];

  List<Ritual> get allRituals => _rituals;

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToRituals(user.uid);
      } else {
        _rituals = [];
        notifyListeners();
      }
    });
  }

  void _listenToRituals(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('rituals')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        // If no rituals exist for new user, seed with defaults
        _seedDefaultRituals(uid);
      } else {
        _rituals = snapshot.docs.map((doc) => Ritual.fromMap(doc.data())).toList();
        notifyListeners();
      }
    });
  }

  Future<void> _seedDefaultRituals(String uid) async {
    final batch = _firestore.batch();
    for (var ritual in _defaultRituals) {
      final docRef = _firestore.collection('users').doc(uid).collection('rituals').doc(ritual.id);
      batch.set(docRef, ritual.toMap());
    }
    await batch.commit();
  }

  Future<void> addRitual(Ritual ritual) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('rituals')
        .doc(ritual.id)
        .set(ritual.toMap());
  }

  Future<void> deleteRitual(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('rituals')
        .doc(id)
        .delete();
  }

  Future<void> toggleStatus(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ritual = _rituals.firstWhere((r) => r.id == id);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('rituals')
        .doc(id)
        .update({'isCompleted': !ritual.isCompleted});
  }

  Future<void> incrementCounter(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ritual = _rituals.firstWhere((r) => r.id == id);
    if (ritual.isCounter && ritual.currentCount < (ritual.goalCount ?? 0)) {
      final newCount = ritual.currentCount + 1;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(id)
          .update({
        'currentCount': newCount,
        'isCompleted': newCount == ritual.goalCount,
      });
    }
  }

  Future<void> decrementCounter(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ritual = _rituals.firstWhere((r) => r.id == id);
    if (ritual.isCounter && ritual.currentCount > 0) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(id)
          .update({
        'currentCount': ritual.currentCount - 1,
        'isCompleted': false,
      });
    }
  }

  List<Milestone> get milestones {
    final completedCount = _rituals.where((r) => r.isCompleted).length;
    final morningRituals = _rituals.where((r) => r.period == RitualPeriod.dawn).toList();
    final morningCompletedCount = morningRituals.where((r) => r.isCompleted).length;
    final allMorningCompleted = morningRituals.isNotEmpty && morningCompletedCount == morningRituals.length;

    return [
      Milestone(
        title: "First Step",
        description: "Complete your first ritual",
        icon: Icons.auto_awesome,
        color: const Color(0xFF3F4177),
        isUnlocked: completedCount >= 1,
      ),
      Milestone(
        title: "Morning Sage",
        description: "Complete all morning rituals",
        icon: Icons.wb_sunny,
        color: const Color(0xFF6B2D8C),
        isUnlocked: allMorningCompleted,
      ),
      Milestone(
        title: "Momentum",
        description: "Complete 3 rituals",
        icon: Icons.speed,
        color: const Color(0xFF2D6B8C),
        isUnlocked: completedCount >= 3,
      ),
      Milestone(
        title: "Zen Master",
        description: "Complete 5 rituals",
        icon: Icons.spa,
        color: const Color(0xFF8C2D4A),
        isUnlocked: completedCount >= 5,
      ),
    ];
  }

  final List<Ritual> _defaultRituals = [
    Ritual(
        id: "1",
        title: "Vedic Meditation",
        subtitle: "Mindfulness session",
        time: "06:00 AM",
        category: RitualCategory.mind,
        focus: RitualFocus.flow,
        period: RitualPeriod.dawn,
        icon: Icons.self_improvement,
        color: AppColors.accentLavender,
        durationMinutes: 20,
        isTimed: true,
        imageUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80&w=500",
        techniques: [
          "Sit in a comfortable position",
          "Close your eyes and breathe naturally",
          "Silently repeat your mantra",
          "Gently return to the mantra if your mind wanders"
        ]),
    Ritual(
        id: "2",
        title: "Morning Exercise",
        subtitle: "Yoga & Stretching",
        time: "06:30 AM",
        category: RitualCategory.body,
        focus: RitualFocus.soft,
        period: RitualPeriod.dawn,
        icon: Icons.fitness_center,
        color: Colors.orangeAccent,
        imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=500",
        techniques: [
          "Start with Child's Pose",
          "Transition to Cat-Cow stretches",
          "Perform 3 Sun Salutations",
          "Hold Downward Dog for 5 breaths"
        ]),
    Ritual(
        id: "5",
        title: "Deep Focus Work",
        subtitle: "Primary Project",
        time: "10:30 AM",
        category: RitualCategory.work,
        focus: RitualFocus.deep,
        period: RitualPeriod.zenith,
        icon: Icons.computer,
        color: AppColors.accentPurple,
        durationMinutes: 90,
        isTimed: true,
        imageUrl: "https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&q=80&w=500",
        techniques: [
          "Clear your workspace of distractions",
          "Set a specific goal for this block",
          "Use noise-canceling headphones",
          "Take no breaks for 90 minutes"
        ]),
    Ritual(
        id: "9",
        title: "Evening Reflection",
        subtitle: "Relax & Unwind",
        time: "09:00 PM",
        category: RitualCategory.soul,
        focus: RitualFocus.soft,
        period: RitualPeriod.dusk,
        icon: Icons.nightlight_round,
        color: AppColors.accentPink,
        imageUrl: "https://images.unsplash.com/photo-1515023115689-589c33041d3c?auto=format&fit=crop&q=80&w=500",
        techniques: [
          "Dim the lights in your room",
          "Review your three biggest wins today",
          "Write down one thing you learned",
          "Plan your most important task for tomorrow"
        ]),
    Ritual(
        id: "10",
        title: "Gratitude Journal",
        subtitle: "Positive mindset",
        time: "10:00 PM",
        category: RitualCategory.soul,
        focus: RitualFocus.flow,
        period: RitualPeriod.dusk,
        icon: Icons.edit_note,
        color: Colors.tealAccent,
        imageUrl: "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&q=80&w=500",
        techniques: [
          "List five things you are grateful for",
          "Describe one positive interaction",
          "Acknowledge a challenge you overcame",
          "End with a positive affirmation"
        ]),
  ];
}
