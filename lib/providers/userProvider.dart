import 'package:flutter/material.dart';
import 'package:shopping_list/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  Future<void> initializeUser(String uid) async {
    try {
      debugPrint('Initializing user with uid: $uid');
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Add retry logic for new user document creation
      int maxRetries = 3;
      int currentTry = 0;
      bool documentFound = false;
      Map<String, dynamic>? userData;

      while (currentTry < maxRetries && !documentFound) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        debugPrint(
            'Attempt ${currentTry + 1}: User document exists: ${userDoc.exists}');

        if (userDoc.exists) {
          documentFound = true;
          userData = userDoc.data() as Map<String, dynamic>;
          debugPrint('User data found: $userData');
        } else {
          currentTry++;
          if (currentTry < maxRetries) {
            debugPrint('Document not found, waiting before retry...');
            await Future.delayed(Duration(milliseconds: 500 * currentTry));
          }
        }
      }

      if (!documentFound || userData == null) {
        throw Exception('User document not found after $maxRetries attempts');
      }

      userData['uid'] = uid; // Ensure uid is included in the data
      final user = User.fromMap(userData);
      debugPrint('User created successfully: ${user.name}');
      _user = user;
      _error = null;
    } catch (e) {
      debugPrint('Error initializing user: $e');
      _error = e.toString();
      _user = null;
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Refresh user data from Firestore
  Future<void> refreshUser() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(_user?.uid).get();
      if (userDoc.exists) {
        _user = User.fromMap(userDoc.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }
}
