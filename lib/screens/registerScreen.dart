import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/providers/userProvider.dart';
import 'package:shopping_list/screens/homeScreen.dart';
import 'package:shopping_list/services/userServices.dart';

class RegisterScreen extends StatefulWidget {
  final String email;
  final String displayName;
  const RegisterScreen({
    super.key,
    required this.email,
    required this.displayName,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  bool error = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.displayName;
  }

  Future<void> _handleRegister() async {
    if (nameController.text.isEmpty) {
      setState(() {
        error = true;
      });
    } else {
      final user =
          await UserServices().createUser(nameController.text, widget.email);
      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.asset('assets/stickers/fridge_sticker.png',
                        height: 200),
                    const SizedBox(height: 50),
                    Text('What should we call you?',
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
                        'Please enter your name to continue',
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
