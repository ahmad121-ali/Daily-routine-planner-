import 'package:flutter/material.dart';

enum RitualCategory { mind, body, work, soul }
enum RitualFocus { flow, deep, soft }
enum RitualPeriod { dawn, zenith, dusk }

class Ritual {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final RitualCategory category;
  final RitualFocus focus;
  final RitualPeriod period;
  final IconData icon;
  final Color color;
  
  // Logic Types
  final bool isTimed;
  final int? durationMinutes;
  
  final bool isCounter;
  final int? goalCount;
  int currentCount; // For tracking water, etc.
  
  bool isCompleted;

  // New fields for Detail View
  final String? imageUrl;
  final List<String>? techniques;

  Ritual({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    required this.focus,
    required this.period,
    required this.icon,
    required this.color,
    this.isTimed = false,
    this.durationMinutes,
    this.isCounter = false,
    this.goalCount,
    this.currentCount = 0,
    this.isCompleted = false,
    this.imageUrl,
    this.techniques,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'category': category.name,
      'focus': focus.name,
      'period': period.name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'colorValue': color.value,
      'isTimed': isTimed,
      'durationMinutes': durationMinutes,
      'isCounter': isCounter,
      'goalCount': goalCount,
      'currentCount': currentCount,
      'isCompleted': isCompleted,
      'imageUrl': imageUrl,
      'techniques': techniques,
    };
  }

  factory Ritual.fromMap(Map<String, dynamic> map) {
    return Ritual(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      time: map['time'] ?? '',
      category: RitualCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => RitualCategory.mind),
      focus: RitualFocus.values.firstWhere((e) => e.name == map['focus'], orElse: () => RitualFocus.flow),
      period: RitualPeriod.values.firstWhere((e) => e.name == map['period'], orElse: () => RitualPeriod.dawn),
      icon: IconData(map['iconCodePoint'] ?? 0, fontFamily: map['iconFontFamily']),
      color: Color(map['colorValue'] ?? 0xFFFFFFFF),
      isTimed: map['isTimed'] ?? false,
      durationMinutes: map['durationMinutes'],
      isCounter: map['isCounter'] ?? false,
      goalCount: map['goalCount'],
      currentCount: map['currentCount'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      imageUrl: map['imageUrl'],
      techniques: map['techniques'] != null ? List<String>.from(map['techniques']) : null,
    );
  }
}
