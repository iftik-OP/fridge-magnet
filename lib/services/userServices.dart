import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list/models/user.dart';

class UserServices {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<User?> createUser(String name, String email) async {
    try {
      // Get current user's UID
      final String uid = _auth.currentUser!.uid;

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'lists': [], // Initialize empty lists array
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create User object
      final User user = User(
        uid: uid,
        name: name,
        email: email,
        lists: [],
      );

      return user;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      userData['uid'] = uid;
      return User.fromMap(userData);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userDoc.docs.isNotEmpty) {
      final userData = userDoc.docs[0].data() as Map<String, dynamic>;
      userData['uid'] = userDoc.docs[0].id;
      return User.fromMap(userData);
    }
    return null;
  }
}
