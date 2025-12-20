import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getDepartments() async {
  final snapshot = await _firestore.collection('department').get();
  return snapshot.docs.map((doc) => doc.data()).toList();
}

Future<Map<String, dynamic>?> getDepartmentById(String departmentId) async {
  final doc = await _firestore.collection('department').doc(departmentId).get();
  if (doc.exists) {
    return doc.data();
  }
  return null;
}