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
    if (e.code == 'user-not-found') {
      throw Exception('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      throw Exception('Wrong password provided.');
    } else if (e.code == 'invalid-email') {
      throw Exception('Invalid email address.');
    }
    throw Exception('Login failed: ${e.message}');
  } catch (e) {
    throw Exception('An error occurred during login.');
  }
}

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
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': user.displayName ?? 'No Name',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'notesCount': 0,
        'likesReceived': 0,
        'savedNotes': 0,
      }, SetOptions(merge: true));
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
