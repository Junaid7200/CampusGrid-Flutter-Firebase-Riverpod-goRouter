import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getDegreesByDepartment(String depId) async {
  final snapshot = await _firestore
      .collection('degree')
      .where('deptId', isEqualTo: depId)
      .get();
  return snapshot.docs.map((doc) => doc.data()).toList();
}

Future<Map<String, dynamic>> getDegreeById(String degId) async {
  final doc = await _firestore.collection('degree').doc(degId).get();
  if (doc.exists) {
    return doc.data()!;
  } else {
    throw Exception('Degree not found.');
  }
}