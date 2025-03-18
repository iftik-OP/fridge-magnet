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
      print('Starting Google Sign-In flow...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      print('Google user email: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      print('Firebase user UID: ${firebaseUser.uid}');

      // Check if user document exists
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      print('User document exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        print('Creating new user document...');
        // Create new user document
        final newUser = app_models.User(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? '',
          lists: [],
          profilePicture: firebaseUser.photoURL, // Add profile picture
        );

        print('New user data: ${newUser.toMap()}');
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        print('User document created successfully');
      } else {
        print('Existing user data: ${userDoc.data()}');
        // Update profile picture if it has changed
        if (userDoc.data()?['profilePicture'] != firebaseUser.photoURL) {
          await _firestore.collection('users').doc(firebaseUser.uid).update({
            'profilePicture': firebaseUser.photoURL,
          });
        }
      }

      return firebaseUser;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get user's shopping lists
}
