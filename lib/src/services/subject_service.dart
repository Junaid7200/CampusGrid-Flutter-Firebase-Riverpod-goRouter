import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getSubjectsByDegree(String degId) async {
  final snapshot = await _firestore
      .collection('subject')
      .where('degId', arrayContains: degId)
      .get();

  return snapshot.docs.map((doc) {
    return {'id': doc.id, ...doc.data()};
  }).toList();
}

Future<Map<String, dynamic>?> getSubjectById(String subId) async {
  final doc = await _firestore.collection('subject').doc(subId).get();
  if (!doc.exists) return null;
  return {'id': doc.id, ...doc.data()!};
}
