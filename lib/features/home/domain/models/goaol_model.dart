import 'package:flutter/material.dart';
import 'package:fitguy1/features/home/domain/models/goal_type.dart';

class FitnessGoal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final Color color;

  FitnessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    required this.color,
  });

  double get progress => currentValue / targetValue;

  FitnessGoal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    double? currentValue,
    double? targetValue,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    Color? color,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
    );
  }
}