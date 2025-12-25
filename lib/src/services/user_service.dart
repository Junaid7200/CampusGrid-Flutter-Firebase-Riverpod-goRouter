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
  if (displayName != null) {
    final userNotes = await _firestore
        .collection('note')
        .where('uploadedBy', isEqualTo: user.uid)
        .get();

    final batch = _firestore.batch();
    for (var doc in userNotes.docs) {
      batch.update(doc.reference, {'uploaderName': displayName});
    }
    await batch.commit();
  }
}

Future<void> updateUserEmail(String newEmail, {String? currentPassword}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  // Check if user signed in with email/password or Google
  final signInMethod = user.providerData.first.providerId;

  if (signInMethod == 'password') {
    // Email/Password user - use password re-auth
    if (currentPassword == null) {
      throw Exception('Password required for email users');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  } else if (signInMethod == 'google.com') {
    // Google user - re-authenticate with Google
    // This would require user to sign in with Google again
    throw Exception(
      'Google users cannot change email. Please contact support.',
    );
    // OR implement Google re-authentication flow
  }

  await user.verifyBeforeUpdateEmail(newEmail);
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
