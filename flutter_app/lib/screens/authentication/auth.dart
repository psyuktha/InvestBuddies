// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_app/home_screen.dart';
import 'package:flutter_app/providers/users_providers.dart';
import 'package:flutter_app/screens/authentication/registeration.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/users_models.dart';

class Auth extends ConsumerStatefulWidget {
  const Auth({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthState createState() => _AuthState();
}

class _AuthState extends ConsumerState<Auth> {
  @override
  // void initState() {
  //   super.initState();
  //   final user = ref.read(userProvider);
  //   print(user.email);
  //   // if (user.email != null) {
  //   //   Navigator.pushReplacement(
  //   //     context,
  //   //     MaterialPageRoute(builder: (context) => HomeScreen()),
  //   //   );
  //   // }
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   final user = ref.read(userProvider);
  //   print('user: $user');
  //   if (user.email != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const RegistrationScreen()),
  //     );
  //   }
  // }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // ignore: invalid_use_of_visible_for_testing_member
        FirebaseFirestore.instance
            .collection('users')
            .doc(_emailController.text)
            .get()
            .then((docSnapshot) {
          // if (docSnapshot.exists) {
          //   ref.read(userProvider.notifier).state = UserModel(
          //     email: _emailController.text,
          //     profileCompleted: false,
          //   );
          // }
          if (docSnapshot.exists) {
            // Map<String, dynamic> data =
            //     docSnapshot.data() as Map<String, dynamic>;
            ref.read(userProvider.notifier).state =
                UserModel.fromFirestore(docSnapshot);
            showSnackBar(context, 'Login successful');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            ref.read(userProvider.notifier).state = UserModel(
              email: _emailController.text,
              profileCompleted: false,
            );
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegistrationScreen()));
          }
        });
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'Login failed');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showSnackBar(context, 'Please fill in all fields');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Invest buddies',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color: Color.fromARGB(255, 0, 57, 103)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Sign Up',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
