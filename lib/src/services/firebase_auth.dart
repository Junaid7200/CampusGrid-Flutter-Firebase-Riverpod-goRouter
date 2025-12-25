import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

bool _isGoogleSignInInitialized = false;


Future<User?> loginWithEmail(String email, String password) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    print("Firebase Auth Error Code: ${e.code}"); 

    if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
      throw Exception('Invalid email or password.');
    } else if (e.code == 'invalid-email') {
      throw Exception('The email address is badly formatted.');
    }
    throw Exception(e.message ?? 'Login failed.');
  } catch (e) {
    throw Exception('An error occurred during login.');
  }
}

// Future<User?> loginWithEmail(String email, String password) async {
//   try {
//     final userCredential = await _auth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     return userCredential.user;
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       throw Exception('No user found for that email.');
//     } else if (e.code == 'wrong-password') {
//       throw Exception('Wrong password provided.');
//     } else if (e.code == 'invalid-email') {
//       throw Exception('Invalid email address.');
//     }
//     throw Exception('Login failed: ${e.message}');
//   } catch (e) {
//     throw Exception('An error occurred during login.');
//   }
// }

Future<User?> signupWithEmail(
  String email,
  String password,
  String displayName,
) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'notesCount': 0,
        'likesReceived': 0,
        'savedNotes': 0,
      });
    }

    return user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      throw Exception('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      throw Exception('An account already exists for that email.');
    } else if (e.code == 'invalid-email') {
      throw Exception('Invalid email address.');
    }
    throw Exception('Signup failed: ${e.message}');
  } catch (e) {
    throw Exception('An error occurred during signup.');
  }
}

Future<void> sendPasswordResetEmail(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('No user found for that email.');
    } else if (e.code == 'invalid-email') {
      throw Exception('Invalid email address.');
    }
    throw Exception('Failed to send reset email: ${e.message}');
  } catch (e) {
    throw Exception('An error occurred. Please try again.');
  }
}

Future<void> initializeGoogleSignIn() async {
  if (!_isGoogleSignInInitialized) {
    try {
      await GoogleSignIn.instance.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      // print('Google Sign-In initialization error: $e');
      rethrow;
    }
  }
}

Future<User?> signInWithGoogle() async {
  try {
    // Ensure Google Sign-In is initialized
    await initializeGoogleSignIn();

    // Create a Completer to handle the event-driven API
    final Completer<GoogleSignInAccount?> completer =
        Completer<GoogleSignInAccount?>();

    // Listen to authentication events
    StreamSubscription<GoogleSignInAuthenticationEvent>? authEventSubscription;
    authEventSubscription = GoogleSignIn.instance.authenticationEvents.listen((
      event,
    ) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        if (!completer.isCompleted) {
          completer.complete(event.user);
          authEventSubscription?.cancel();
        }
      }
    });

    // Trigger the authentication
    await GoogleSignIn.instance.authenticate();

    // Wait for the user from the event stream
    final GoogleSignInAccount? googleUser = await completer.future.timeout(
      Duration(seconds: 30),
      onTimeout: () {
        authEventSubscription?.cancel();
        return null;
      },
    );

    // Cancel the subscription
    authEventSubscription.cancel();

    if (googleUser == null) {
      throw Exception('Google sign-in was canceled');
    }

    // Get the authentication tokens
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential for Firebase
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    // Create or update user document in Firestore
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        // Existing user - only update display name and email
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': user.displayName ?? 'No Name',
          'email': user.email,
        });
      } else {
        // New user - initialize with default values
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': user.displayName ?? 'No Name',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'notesCount': 0,
          'likesReceived': 0,
          'savedNotes': 0,
        });
      }
    }

    return user;
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      throw Exception('Sign-in was canceled');
    } else if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
      throw Exception('Configuration error. Please contact support.');
    }
    throw Exception('Google sign-in failed: ${e.description}');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'account-exists-with-different-credential') {
      throw Exception('An account already exists with the same email address.');
    } else if (e.code == 'invalid-credential') {
      throw Exception('Invalid credential. Please try again.');
    }
    throw Exception('Firebase authentication failed: ${e.message}');
  } catch (e) {
    throw Exception('An error occurred during Google sign-in.');
  }
}

Future<void> logout() async {
  await GoogleSignIn.instance.signOut();
  await _auth.signOut();
}


Future<void> deleteAccount() async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userId = user.uid;

    // 1. Delete user's notes
    final notesSnapshot = await _firestore
        .collection('note')
        .where('uploadedBy', isEqualTo: userId)
        .get();
    
    for (var noteDoc in notesSnapshot.docs) {
      final noteId = noteDoc.id;
      final subId = noteDoc.data()['subId'];
      
      // Delete note document
      await noteDoc.reference.delete();
      
      // Update subject's notesCount
      if (subId != null) {
        await _firestore.collection('subject').doc(subId).update({
          'notesCount': FieldValue.increment(-1),
        });
      }
      
      // Delete all likes for this note
      final likesSnapshot = await _firestore
          .collection('likes')
          .where('noteId', isEqualTo: noteId)
          .get();
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

    // 2. Delete user's likes (on other people's notes)
    final userLikesSnapshot = await _firestore
        .collection('likes')
        .where('userId', isEqualTo: userId)
        .get();
    
    for (var likeDoc in userLikesSnapshot.docs) {
      final noteId = likeDoc.data()['noteId'];
      await likeDoc.reference.delete();
      
      // Decrement the note's likesCount
      await _firestore.collection('note').doc(noteId).update({
        'likesCount': FieldValue.increment(-1),
      });
    }

    // 3. Delete user's saved notes
    final userSavesSnapshot = await _firestore
        .collection('savedNotes')
        .where('userId', isEqualTo: userId)
        .get();
    
    for (var saveDoc in userSavesSnapshot.docs) {
      await saveDoc.reference.delete();
    }

    // 4. Delete user document from Firestore
    await _firestore.collection('users').doc(userId).delete();

    // 5. Sign out from Google if signed in
    await GoogleSignIn.instance.signOut();

    // 6. Delete Firebase Auth account
    await user.delete();

  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      throw Exception(
        'For security, please log out and log back in before deleting your account.',
      );
    }
    throw Exception('Account deletion failed: ${e.message}');
  } catch (e) {
    throw Exception('An error occurred while deleting account: $e');
  }
}
