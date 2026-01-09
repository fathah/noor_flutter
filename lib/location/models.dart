class NoorLocation {
  final int id;
  final String name;

  NoorLocation({required this.id, required this.name});

  factory NoorLocation.fromJson(Map<String, dynamic> json) {
    return NoorLocation(id: json['id'], name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
