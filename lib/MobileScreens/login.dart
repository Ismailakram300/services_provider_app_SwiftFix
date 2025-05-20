import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:serviceapp/MobileScreens/Worker_Screens/Show_request.dart';
import 'package:serviceapp/MobileScreens/user_home_screen.dart';
import 'package:serviceapp/MobileScreens/signup.dart';
import 'package:serviceapp/MobileScreens/Worker_Screens/worker_home_screen.dart';
import '../utils/custome-button.dart';
import 'Worker_Screens/worker_btm_nav.dart';
import 'bottom_nav_mobile.dart';


class LoginM extends StatefulWidget {
  const LoginM({super.key});

  @override
  State<LoginM> createState() => _LoginMState();
}

class _LoginMState extends State<LoginM> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {

        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final user = userCredential.user;
        if (user != null) {
          print("Current User: ${user.uid}");
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            String role = userDoc.get('role');
            print("User role fetched: $role");
            if (role == 'user') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login Successful!')),
              );
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => BottomNavMobile()));
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WorkerBottomNavMobile()), // Regular home screen
              );
            }
          } else {
            print("User document not found in Firestore.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User not found in Firestore")),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred';
        if (e.code == 'user-not-found') {
          message = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/logopng.png',
                      height: 100,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Login with Email and Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email input field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password input field with visibility toggle
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : MyElevatedButton(
                                  onPressed:  _loginUser,
                                  text: "LogIn",
                                ),
                          const SizedBox(height: 15),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to sign up screen
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpM()));
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


