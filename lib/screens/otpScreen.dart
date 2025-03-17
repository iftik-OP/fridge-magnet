import 'package:flutter/material.dart';
import 'package:shopping_list/services/firebaseServices.dart';

class OTPScreen extends StatelessWidget {
  final String phoneNumber;
  final String verificationId;
  OTPScreen(
      {super.key, required this.phoneNumber, required this.verificationId});
  final TextEditingController otpController = TextEditingController();

  void _handleVerify(BuildContext context) {
    FirebaseServices()
        .signInWithPhoneNumber(verificationId, otpController.text, phoneNumber, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enter the\ncode sent to',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 30)),
                          const SizedBox(height: 10),
                          Text('+91 $phoneNumber',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontSize: 16)),
                          // Text('FRIDGE\nMAGNET',
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .headlineLarge
                          //         ?.copyWith(
                          //             fontWeight: FontWeight.w900, fontSize: 40)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Image.asset('assets/stickers/nine_nine.png', width: 150),
                    ],
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                        _handleVerify(context);
                      },
                      child: const Text('Verify'),
                    ),
                  )
                ],
              ),
              Text('FRIDGE\nMAGNET',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade300)),
            ],
          )),
    );
  }
}
