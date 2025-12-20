import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String? getCurrentUserDisplayName() {
  final user = _auth.currentUser;
  return user?.displayName;
}

String? getCurrentUserEmail() {
  final user = _auth.currentUser;
  return user?.email;
}

Future<Map<String, dynamic>> getUserProfile(String userId) async {
  final doc = await _firestore.collection('users').doc(userId).get();
  if (doc.exists) {
    return doc.data()!;
  } else {
    throw Exception('User profile not found.');
  }
}

Future<Map<String, dynamic>?> getCurrentUserProfile() async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) return null;
  return getUserProfile(userId);
}

Future<void> updateUserProfile({String? displayName, String? email}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Update Firebase Auth profile
  if (displayName != null) {
    await user.updateDisplayName(displayName);
  }
  if (email != null) {
    await user.updateEmail(email);
  }

  // Update Firestore document
  final updates = <String, dynamic>{};
  if (displayName != null) updates['displayName'] = displayName;
  if (email != null) updates['email'] = email;

  if (updates.isNotEmpty) {
    await _firestore.collection('users').doc(user.uid).update(updates);
  }
}

Future<int> getUserNotesCount(String userId) async {
  final snapshot = await _firestore
      .collection('notes')
      .where('ownerId', isEqualTo: userId)
      .get();
  return snapshot.docs.length;
}

Future<int> getUserLikesReceived(String userId) async {
  final snapshot = await _firestore
      .collection('notes')
      .where('uploadedBy', isEqualTo: userId)
      .get();
      int totalLikes = 0;
      for (var doc in snapshot.docs) {
        totalLikes += (doc.data()['likesCount'] as int?) ?? 0;
      }
  return totalLikes;
}
