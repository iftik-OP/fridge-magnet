import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/screens/homeScreen.dart';
import 'package:shopping_list/screens/otpScreen.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        print('verificationCompleted');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      phoneNumber: phoneNumber,
                      verificationId: verificationId,
                    )));
        print('Code sent to +91$phoneNumber');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signInWithPhoneNumber(
      String verificationId, String smsCode, BuildContext context) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const ShoppingListScreen()),
      (route) => false,
    );
  }
}
