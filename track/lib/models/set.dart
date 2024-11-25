class Set {
  int reps;
  double weight;
  DateTime? timestamp;

  Set({
    this.reps = 0,
    this.weight = 0,
    this.timestamp,
  });

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
      reps: json['reps'],
      weight: json['weight'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}