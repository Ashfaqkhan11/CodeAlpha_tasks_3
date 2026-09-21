import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/db_helper.dart';
import '../models/activity_model.dart';

class FitnessProvider extends ChangeNotifier {
  List<ActivityModel> _activities = [];
  int _stepCount = 3450; // Initial dummy count fallback
  int _stepGoal = 10000;
  int _calorieGoal = 2000;
  int _waterIntake = 1500; // in ml
  double _sleepHours = 7.5;

  List<ActivityModel> get activities => _activities;
  int get stepCount => _stepCount;
  int get stepGoal => _stepGoal;
  int get calorieGoal => _calorieGoal;
  int get waterIntake => _waterIntake;
  double get sleepHours => _sleepHours;

  FitnessProvider() {
    loadData();
    initPedometer();
  }

  Future<void> loadData() async {
    _activities = await DBHelper.instance.getAllActivities();
    final goals = await DBHelper.instance.getGoals();
    _stepGoal = goals['step_goal']!;
    _calorieGoal = goals['calorie_goal']!;
    notifyListeners();
  }

  // Total Calories burned today
  int get todayCalories {
    final now = DateTime.now();
    return _activities
        .where((a) =>
    a.date.year == now.year &&
        a.date.month == now.month &&
        a.date.day == now.day)
        .fold(0, (sum, a) => sum + a.calories);
  }

  // Total Workout minutes today
  int get todayWorkoutMinutes {
    final now = DateTime.now();
    return _activities
        .where((a) =>
    a.date.year == now.year &&
        a.date.month == now.month &&
        a.date.day == now.day)
        .fold(0, (sum, a) => sum + a.duration);
  }

  Future<void> addActivity(ActivityModel activity) async {
    await DBHelper.instance.insertActivity(activity);
    await loadData();
  }

  Future<void> deleteActivity(int id) async {
    await DBHelper.instance.deleteActivity(id);
    await loadData();
  }

  Future<void> setGoals(int stepGoal, int calorieGoal) async {
    _stepGoal = stepGoal;
    _calorieGoal = calorieGoal;
    await DBHelper.instance.updateGoals(stepGoal, calorieGoal);
    notifyListeners();
  }

  void addWater(int ml) {
    _waterIntake += ml;
    notifyListeners();
  }

  // Pedometer sensor setup
  void initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      Pedometer.stepCountStream.listen(
            (StepCount event) {
          _stepCount = event.steps;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Pedometer error: $error');
        },
      );
    }
  }
}