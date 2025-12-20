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

Future<void> updateUserProfile({String? displayName}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Update Firebase Auth profile
  if (displayName != null) {
    await user.updateDisplayName(displayName);

    // Update Firestore document
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName,
    });
  }
}

Future<void> updateUserEmail(String newEmail, String currentPassword) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Re-authenticate user first
  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
  );
  await user.reauthenticateWithCredential(credential);

  // Now update email
  await user.verifyBeforeUpdateEmail(newEmail);

  // Update Firestore after verification
  await _firestore.collection('users').doc(user.uid).update({
    'email': newEmail,
  });
}

Future<int> getUserNotesCount(String userId) async {
  final snapshot = await _firestore
      .collection('note')
      .where('uploadedBy', isEqualTo: userId)
      .get();
  return snapshot.docs.length;
}

Future<int> getUserLikesReceived(String userId) async {
  final snapshot = await _firestore
      .collection('note')
      .where('uploadedBy', isEqualTo: userId)
      .get();
  int totalLikes = 0;
  for (var doc in snapshot.docs) {
    totalLikes += (doc.data()['likesCount'] as int?) ?? 0;
  }
  return totalLikes;
}

String? getCurrentUserId() {
  final user = _auth.currentUser;
  return user?.uid;
}
