class Job {
  final String name;
  final int ratePerHour;
  final String id;

  Job({required this.id, required this.name, required this.ratePerHour});
  factory Job.fromMap(Map<String, dynamic> data, String documentId) {
    final String name = data['name'];
    final int ratePerHour = data['ratePerHour'];
    return Job(name: name, ratePerHour: ratePerHour, id: documentId);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'ratePerHour': ratePerHour};
  }
}
