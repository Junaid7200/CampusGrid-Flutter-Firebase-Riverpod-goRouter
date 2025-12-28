import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Universal search across degrees, subjects, and notes
Future<Map<String, List<Map<String, dynamic>>>> searchAll(
  String query, {
  bool searchDegrees = true,
  bool searchSubjects = true,
  bool searchNotes = true,
}) async {
  final results = <String, List<Map<String, dynamic>>>{
    'degrees': [],
    'subjects': [],
    'notes': [],
  };

  if (query.isEmpty) return results;

  final lowerQuery = query.toLowerCase();

  // Search degrees
  if (searchDegrees) {
    final degreesSnapshot = await _firestore.collection('degree').get();
    results['degrees'] = degreesSnapshot.docs
        .where((doc) {
          final name = (doc.data()['name'] as String?)?.toLowerCase() ?? '';
          return name.contains(lowerQuery);
        })
        .map((doc) {
          return {'id': doc.id, ...doc.data()};
        })
        .toList();
  }

  // Search subjects
  if (searchSubjects) {
    final subjectsSnapshot = await _firestore.collection('subject').get();
    results['subjects'] = subjectsSnapshot.docs
        .where((doc) {
          final name = (doc.data()['name'] as String?)?.toLowerCase() ?? '';
          return name.contains(lowerQuery);
        })
        .map((doc) {
          return {'id': doc.id, ...doc.data()};
        })
        .toList();
  }

  // Search notes
  if (searchNotes) {
    final notesSnapshot = await _firestore.collection('note').get();
    results['notes'] = notesSnapshot.docs
        .where((doc) {
          final title = (doc.data()['title'] as String?)?.toLowerCase() ?? '';
          final description =
              (doc.data()['description'] as String?)?.toLowerCase() ?? '';
          return title.contains(lowerQuery) || description.contains(lowerQuery);
        })
        .map((doc) {
          return {'id': doc.id, ...doc.data()};
        })
        .toList();
  }

  return results;
}