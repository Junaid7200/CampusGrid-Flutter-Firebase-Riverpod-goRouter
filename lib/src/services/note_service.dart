import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_grid/src/services/user_service.dart' as user_service;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

// Fetch most liked notes (for home page)
Future<List<Map<String, dynamic>>> getMostLikedNotes({int limit = 10}) async {
  final snapshot = await _firestore
      .collection('note')
      .orderBy('likesCount', descending: true)
      .limit(limit)
      .get();

  return snapshot.docs.map((doc) {
    return {'id': doc.id, ...doc.data()};
  }).toList();
}

// Fetch recently added notes (for home page)
Future<List<Map<String, dynamic>>> getRecentNotes({int limit = 10}) async {
  final snapshot = await _firestore
      .collection('note')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .get();

  return snapshot.docs.map((doc) {
    return {'id': doc.id, ...doc.data()};
  }).toList();
}

// Fetch notes by subject
Future<List<Map<String, dynamic>>> getNotesBySubject(String subId) async {
  final snapshot = await _firestore
      .collection('note')
      .where('subId', isEqualTo: subId)
      // Note: If you get index error, create composite index in Firebase Console
      // or temporarily comment out orderBy below
      // .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs.map((doc) {
    return {'id': doc.id, ...doc.data()};
  }).toList();
}

// Fetch user's own notes
Future<List<Map<String, dynamic>>> getUserNotes(String userId) async {
  final snapshot = await _firestore
      .collection('note')
      .where('uploadedBy', isEqualTo: userId)
      // .orderBy('createdAt', descending: true) // i removed this and then it worked in the profiles page weirdly
      .get();

  return snapshot.docs.map((doc) {
    return {'id': doc.id, ...doc.data()};
  }).toList();
}

// Get note by ID
Future<Map<String, dynamic>?> getNoteById(String noteId) async {
  final doc = await _firestore.collection('note').doc(noteId).get();
  if (!doc.exists) return null;
  return {'id': doc.id, ...doc.data()!};
}

// Create a note (NO dptId, degId - they're not in your schema!)
Future<String> createNote({
  required String title,
  required String description,
  required String fileUrl,
  required String fileName,
  required String fileType,
  required String subId,
}) async {
  final user = _auth.currentUser;
  // fetch user displayName from the users collection:
  Map<String, dynamic> profile = await user_service.getUserProfile(user!.uid);
  String uploaderName = profile['displayName'] ?? 'Unknown';
  // if (user == null) throw Exception('No user logged in');

  final docRef = await _firestore.collection('note').add({
    'title': title,
    'description': description,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileType': fileType,
    'subId': subId,
    'uploadedBy': user.uid,
    'uploaderName': uploaderName,
    'likesCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Update subject's notesCount
  await _firestore.collection('subject').doc(subId).update({
    'notesCount': FieldValue.increment(1),
  });
  // udpate notesCount in user document
  await _firestore.collection('users').doc(user.uid).update({
    'notesCount': FieldValue.increment(1),
  });

  return docRef.id;
}

// Update a note
Future<void> updateNote({
  required String noteId,
  String? title,
  String? description,
  String? fileUrl,
  String? fileName,
  String? fileType,
}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Check if user owns the note
  final doc = await _firestore.collection('note').doc(noteId).get();
  if (doc.data()?['uploadedBy'] != user.uid) {
    throw Exception('You can only edit your own notes');
  }

  final updates = <String, dynamic>{};
  if (title != null) updates['title'] = title;
  if (description != null) updates['description'] = description;
  if (fileUrl != null) updates['fileUrl'] = fileUrl;
  if (fileName != null) updates['fileName'] = fileName;
  if (fileType != null) updates['fileType'] = fileType;

  if (updates.isNotEmpty) {
    await _firestore.collection('note').doc(noteId).update(updates);
  }
}

// Delete a note
Future<void> deleteNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Check if user owns the note
  final doc = await _firestore.collection('note').doc(noteId).get();
  final noteData = doc.data();
  if (noteData?['uploadedBy'] != user.uid) {
    throw Exception('You can only delete your own notes');
  }

  // Delete the note
  await _firestore.collection('note').doc(noteId).delete();

  // Update subject's notesCount
  await _firestore.collection('subject').doc(noteData!['subId']).update({
    'notesCount': FieldValue.increment(-1),
  });
  // decrement notesCount in user document
  await _firestore.collection('users').doc(user.uid).update({
    'notesCount': FieldValue.increment(-1),
  });

  // if it was a savedNote then decrement savedNotes count in user document
  final savedSnapshot = await _firestore
      .collection('savedNotes')
      .where('noteId', isEqualTo: noteId)
      .get();
  if (savedSnapshot.docs.isNotEmpty) {
    await _firestore.collection('users').doc(user.uid).update({
      'savedNotes': FieldValue.increment(-1),
    });
  }
  // if it was liked then decrement likesReceived count in user document
  final likesSnapshot = await _firestore
      .collection('likes')
      .where('noteId', isEqualTo: noteId)
      .get();
  if (likesSnapshot.docs.isNotEmpty) {
    await _firestore.collection('users').doc(user.uid).update({
      'likesReceived': FieldValue.increment(-1),
    });
  }

  // Delete all likes for this note
  for (var likeDoc in likesSnapshot.docs) {
    await likeDoc.reference.delete();
  }

  // Delete all saves for this note
  final savesSnapshot = await _firestore
      .collection('savedNotes')
      .where('noteId', isEqualTo: noteId)
      .get();
  for (var saveDoc in savesSnapshot.docs) {
    await saveDoc.reference.delete();
  }
}

// Like a note
Future<void> likeNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  final likeId = '${user.uid}_$noteId';

  // Check if already liked
  final likeDoc = await _firestore.collection('likes').doc(likeId).get();
  if (likeDoc.exists) {
    throw Exception('Already liked this note');
  }

  // Create like document
  await _firestore.collection('likes').doc(likeId).set({
    'userId': user.uid,
    'noteId': noteId,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Increment likesCount
  await _firestore.collection('note').doc(noteId).update({
    'likesCount': FieldValue.increment(1),
  });
  // increment likesCount of that user as well
  final noteDoc = await _firestore.collection('note').doc(noteId).get();
  final noteData = noteDoc.data();
  final noteOwnerId = noteData?['uploadedBy'];
  if (noteOwnerId != null) {
    await _firestore.collection('users').doc(noteOwnerId).update({
      'likesReceived': FieldValue.increment(1),
    });
  }
}

// Unlike a note
Future<void> unlikeNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  final likeId = '${user.uid}_$noteId';

  // Delete like document
  await _firestore.collection('likes').doc(likeId).delete();

  // Decrement likesCount
  await _firestore.collection('note').doc(noteId).update({
    'likesCount': FieldValue.increment(-1),
  });
  // decrement likesCount of that user as well
  final noteDoc = await _firestore.collection('note').doc(noteId).get();
  final noteData = noteDoc.data();
  final noteOwnerId = noteData?['uploadedBy'];
  if (noteOwnerId != null) {
    await _firestore.collection('users').doc(noteOwnerId).update({
      'likesReceived': FieldValue.increment(-1),
    });
  }
}

// Check if user liked a note
Future<bool> hasUserLikedNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) return false;

  final likeId = '${user.uid}_$noteId';
  final doc = await _firestore.collection('likes').doc(likeId).get();
  return doc.exists;
}

// Save a note
Future<void> saveNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  final saveId = '${user.uid}_$noteId';

  // Check if already saved
  final saveDoc = await _firestore.collection('savedNotes').doc(saveId).get();
  if (saveDoc.exists) {
    throw Exception('Already saved this note');
  }

  // Create save document
  await _firestore.collection('savedNotes').doc(saveId).set({
    'userId': user.uid,
    'noteId': noteId,
    'savedAt': FieldValue.serverTimestamp(),
  });
  // increment savedCount in user document
  await _firestore.collection('users').doc(user.uid).update({
    'savedNotes': FieldValue.increment(1),
  });
}

// Unsave a note
Future<void> unsaveNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  final saveId = '${user.uid}_$noteId';
  await _firestore.collection('savedNotes').doc(saveId).delete();
  // decrement savedCount in user document
  await _firestore.collection('users').doc(user.uid).update({
    'savedNotes': FieldValue.increment(-1),
  });
}

// Check if user saved a note
Future<bool> hasUserSavedNote(String noteId) async {
  final user = _auth.currentUser;
  if (user == null) return false;

  final saveId = '${user.uid}_$noteId';
  final doc = await _firestore.collection('savedNotes').doc(saveId).get();
  return doc.exists;
}

// Get user's saved notes
Future<List<Map<String, dynamic>>> getUserSavedNotes() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Get saved note IDs
  final savedSnapshot = await _firestore
      .collection('savedNotes')
      .where('userId', isEqualTo: user.uid)
      .get();

  final noteIds = savedSnapshot.docs
      .map((doc) => doc.data()['noteId'] as String)
      .toList();

  if (noteIds.isEmpty) return [];

  // Firestore 'in' query limited to 10 items, so batch it
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
  return allNotes;
}
