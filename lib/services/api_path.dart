class APIPath {
  static String job(String uid, String jobID) =>
      'users/$uid/jobs/$jobID'; //Location in Firestore
  static String jobs(String uid) => 'users/$uid/jobs';
}
