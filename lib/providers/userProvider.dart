import 'package:flutter/material.dart';
import 'package:shopping_list/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> initializeUser(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final user = User(
          uid: uid,
          name: userData['name'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          lists: [], // Initialize with empty list, lists will be loaded separately
        );
        setUser(user);
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
      rethrow;
    }
  }
}
