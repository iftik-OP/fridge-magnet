import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/providers/userProvider.dart';
import 'package:shopping_list/screens/homeScreen.dart';
import 'package:shopping_list/screens/otpScreen.dart';
import 'package:shopping_list/screens/registerScreen.dart';
import 'package:shopping_list/services/userServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list/models/user.dart' as app_models;
import 'package:shopping_list/models/list.dart';

class FirebaseServices {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? verificationId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<auth.User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign In was aborted by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        print('Firebase user is null after Google Sign In');
        return null;
      }

      print('Google Sign In successful for user: ${firebaseUser.email}');

      // Check if user exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Create new user document if it doesn't exist
        final newUser = app_models.User(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? 'Unknown User',
          lists: [],
          profilePicture: firebaseUser.photoURL,
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        print('Created new user document for: ${newUser.name}');
      } else {
        // Update profile picture if it has changed
        final currentUser = app_models.User.fromMap(userDoc.data()!);
        if (currentUser.profilePicture != firebaseUser.photoURL) {
          await _firestore.collection('users').doc(firebaseUser.uid).update({
            'profilePicture': firebaseUser.photoURL,
          });
          print('Updated profile picture for: ${currentUser.name}');
        }
      }

      return firebaseUser;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get user's shopping lists
}
