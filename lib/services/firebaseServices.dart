import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/providers/userProvider.dart';
import 'package:shopping_list/screens/homeScreen.dart';
import 'package:shopping_list/screens/otpScreen.dart';
import 'package:shopping_list/screens/registerScreen.dart';
import 'package:shopping_list/services/userServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list/models/list.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> signInWithPhoneNumber(String verificationId, String smsCode,
      String phoneNumber, BuildContext context) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    final user = await UserServices().getUser(_auth.currentUser!.uid);
    print(user!.uid);
    if (user != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterScreen(
                    phoneNumber: phoneNumber,
                  )),
          (route) => false);
    }
  }

  // Get user's shopping lists
}
