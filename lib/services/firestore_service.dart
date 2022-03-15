import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._(); //private constructor
  static final instance = FirestoreService._();

  Future<void> setData(
      {required String path, required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    // print("path : $path  ||  data : $data");
    await reference.set(data);
  }

  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('delete: $path');
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>(
      {required String path,
      required T Function(Map<String, dynamic> data, String documentId)
          builder}) {
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((collection) => collection.docs
        .map((document) => builder(document.data(), document.id))
        .toList());
  }
}
