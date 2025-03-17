import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/providers/userProvider.dart';
import 'package:shopping_list/screens/homeScreen.dart';
import 'package:shopping_list/services/userServices.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;
  const RegisterScreen({super.key, required this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  bool error = false;

  Future<void> _handleRegister() async {
    if (nameController.text.isEmpty) {
      setState(() {
        error = true;
      });
    } else {
      final user = await UserServices()
          .createUser(nameController.text, widget.phoneNumber);
      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeScreen()),
            (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height - 48, // Account for padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Transform.rotate(
                      angle: 0 * 3.14159 / 180,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(-2, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                            'assets/stickers/hawkeye-asking-name.gif',
                            width: 150),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                        'Obviously we can\'t call you ${widget.phoneNumber}, So what should we call you?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 10),
                    const SizedBox(height: 50),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleRegister();
                        },
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (error)
                      const Text(
                        'We don\'t have enough space for your number so just enter your name!!',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
                Text('FRIDGE\nMAGNET',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade300)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
