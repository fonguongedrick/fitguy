import 'package:flutter/material.dart';
enum GoalType {
  calorie,
  workout,
  water,
  steps,
  weight,
  custom,
}

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.calorie:
        return 'Calorie Intake';
      case GoalType.workout:
        return 'Workout Time';
      case GoalType.water:
        return 'Water Intake';
      case GoalType.steps:
        return 'Step Count';
      case GoalType.weight:
        return 'Weight Target';
      case GoalType.custom:
        return 'Custom Goal';
    }
  }

  String get defaultUnit {
    switch (this) {
      case GoalType.calorie:
        return 'kcal';
      case GoalType.workout:
        return 'minutes';
      case GoalType.water:
        return 'glasses';
      case GoalType.steps:
        return 'steps';
      case GoalType.weight:
        return 'kg';
      case GoalType.custom:
        return 'units';
    }
  }

  IconData get icon {
    switch (this) {
      case GoalType.calorie:
        return Icons.local_fire_department;
      case GoalType.workout:
        return Icons.fitness_center;
      case GoalType.water:
        return Icons.water_drop;
      case GoalType.steps:
        return Icons.directions_walk;
      case GoalType.weight:
        return Icons.monitor_weight;
      case GoalType.custom:
        return Icons.flag;
    }
  }

  Color get defaultColor {
    switch (this) {
      case GoalType.calorie:
        return Colors.orange;
      case GoalType.workout:
        return Colors.red;
      case GoalType.water:
        return Colors.blue;
      case GoalType.steps:
        return Colors.green;
      case GoalType.weight:
        return Colors.purple;
      case GoalType.custom:
        return Colors.teal;
    }
  }
}