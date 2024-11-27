// Model for muscle
// just a name e.g. "Biceps"
class Muscle {
  final int id;
  final String name;

  Muscle({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Muscle.fromJson(Map<String, dynamic> json) {
    return Muscle(id: json['id'], name: json['name']);
  }
}
