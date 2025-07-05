import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitguy1/features/home/domain/models/goaol_model.dart';

final goalProvider = StateNotifierProvider<GoalNotifier, List<FitnessGoal>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<FitnessGoal>> {
  GoalNotifier() : super([]);

  void addGoal(FitnessGoal goal) {
    state = [...state, goal];
  }

  void updateGoal(String id, FitnessGoal updatedGoal) {
    state = state.map((goal) => goal.id == id ? updatedGoal : goal).toList();
  }

  void deleteGoal(String id) {
    state = state.where((goal) => goal.id != id).toList();
  }

  void updateProgress(String id, double newValue) {
    state = state.map((goal) {
      if (goal.id == id) {
        return goal.copyWith(currentValue: newValue);
      }
      return goal;
    }).toList();
  }
}