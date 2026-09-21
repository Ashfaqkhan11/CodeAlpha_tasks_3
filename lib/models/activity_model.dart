class ActivityModel {
  final int? id;
  final String type; // Running, Cycling, Gym, Yoga, Walking, Other
  final int duration; // In minutes
  final int calories;
  final DateTime date;

  ActivityModel({
    this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }
}