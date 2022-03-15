import 'package:time_tracker/app/home/models/job.dart';
import 'package:time_tracker/services/api_path.dart';
import 'package:time_tracker/services/firestore_service.dart';

abstract class Database {
  Future<void> setJob(Job job);
  Future<void> deleteJob(Job job);
  Stream<List<Job>> jobStream();
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({required this.uid});
  final String uid;
  final _service = FirestoreService.instance;

  @override
  Future<void> setJob(Job job) =>
      _service.setData(path: APIPath.job(uid, job.id), data: job.toMap());

  @override
  Future<void> deleteJob(Job job) =>
      _service.deleteData(path: APIPath.job(uid, job.id));

  @override
  Stream<List<Job>> jobStream() => _service.collectionStream(
      path: APIPath.jobs(uid),
      builder: (data, documentId) =>
          Job.fromMap(data, documentId)); //Job.fromMap returns a Job
}
