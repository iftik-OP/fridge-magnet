import 'package:flutter/material.dart';
import 'package:shopping_list/services/firebaseServices.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController phoneController = TextEditingController();

  void _handleLogin(BuildContext context) {
    FirebaseServices().verifyPhoneNumber(phoneController.text, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Login to',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 10),
                    Text('FRIDGE\nMAGNET',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w900, fontSize: 40)),
                  ],
                ),
                const SizedBox(width: 10),
                Image.asset('assets/stickers/fridge_sticker.png', width: 150),
              ],
            ),
            const SizedBox(height: 50),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                hintText: 'Enter your phone number',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                counterText: '', // Hides the character counter
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleLogin(context);
                },
                child: const Text('Login'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
