// Exercise model
// consists of an id, name, and a list of muscleIds
class Exercise {
  final int id;
  final String name;
  final List<int> muscleIds;

  Exercise({required this.id, required this.name, required this.muscleIds});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleIds': muscleIds,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      muscleIds: List<int>.from(json['muscleIds']),
    );
  }
}
