import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

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

// Search saved notes
Future<List<Map<String, dynamic>>> searchSavedNotes(String query) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Get user's saved note IDs
  final savedSnapshot = await _firestore
      .collection('savedNotes')
      .where('userId', isEqualTo: user.uid)
      .get();

  final noteIds = savedSnapshot.docs
      .map((doc) => doc.data()['noteId'] as String)
      .toList();

  if (noteIds.isEmpty) return [];

  // Fetch notes in batches
  List<Map<String, dynamic>> allNotes = [];
  for (int i = 0; i < noteIds.length; i += 10) {
    final batch = noteIds.skip(i).take(10).toList();
    final notesSnapshot = await _firestore
        .collection('note')
        .where(FieldPath.documentId, whereIn: batch)
        .get();

    allNotes.addAll(
      notesSnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList(),
    );
  }

  // Filter by query
  if (query.isEmpty) return allNotes;

  final lowerQuery = query.toLowerCase();
  return allNotes.where((note) {
    final title = (note['title'] as String?)?.toLowerCase() ?? '';
    final description = (note['description'] as String?)?.toLowerCase() ?? '';
    return title.contains(lowerQuery) || description.contains(lowerQuery);
  }).toList();
}
