class Set {
  final int reps;
  final double weight;
  final DateTime timestamp;

  Set({
    required this.reps,
    required this.weight,
    required this.timestamp,
  });

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
      reps: json['reps'],
      weight: json['weight'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
