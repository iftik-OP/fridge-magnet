import 'package:flutter/material.dart';
import 'package:shopping_list/services/firebaseServices.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handleGoogleSignIn(BuildContext context) {
    FirebaseServices().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 300;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (isSmallScreen) {
                      return Column(
                        children: [
                          _buildWelcomeText(context),
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/stickers/fridge_sticker.png',
                            height: screenSize.height * 0.25,
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWelcomeText(context),
                          Image.asset(
                            'assets/stickers/fridge_sticker.png',
                            height: screenSize.height * 0.18,
                          ),
                        ],
                      );
                    }
                  },
                ),
                SizedBox(height: screenSize.height * 0.08),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleGoogleSignIn(context),
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
        ),
        Text(
          'FRIDGE\nMAGNET',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 40,
              ),
        ),
      ],
    );
  }
}
