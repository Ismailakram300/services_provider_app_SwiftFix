import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serviceapp/MobileScreens/login.dart';

import 'package:http/http.dart' as http;
import '../data/firebase_auth_services.dart';
import '../utils/custom_text.dart';
import '../utils/custome-button.dart';
import '../utils/custome_form.dart';

class SignUpM extends StatefulWidget {
  const SignUpM({super.key});

  @override
  State<SignUpM> createState() => _SignUpMState();
}

class _SignUpMState extends State<SignUpM> {
  void initState() {
    super.initState();
    fetchCities(); // Fetch cities when the screen loads
  }

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  //final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessDetailsController =
      TextEditingController();
  bool _isLoading = false;
  XFile? _selectedImage; // Store the selected image
  String? _selectedCity;
  String? _businessNameController; // Store the selected city
  bool _isServiceProvider = false;
  final ImagePicker _picker = ImagePicker();
  // Selected city
  bool isLoading = true;

  Future<void> fetchCities() async {
    var headers = {
      'X-CSCAPI-KEY':
          'MHZFblJ0WktwS0ZlNU4zOVJqWDUzSFRnM0ZTMzZCYVMzYWZFRVZRZw==', // Replace with your actual API key
    };

    var request = http.Request(
      'GET',
      Uri.parse(
          'https://api.countrystatecity.in/v1/countries/PK/cities'), // Pakistan's endpoint
    );

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Decode the response and extract city names
        String responseBody = await response.stream.bytesToString();
        List<dynamic> citiesData = jsonDecode(responseBody);

        setState(() {
          cities = citiesData
              .map<String>((city) => city['name'].toString())
              .toList();
          isLoading = false; // Data has been loaded
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading in case of an error
        });
        print("Failed to fetch cities: ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading in case of an error
      });
      print("Error fetching cities: $e");
    }
  }

  // Method to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }
// Method to validate if an image is selected
  bool _validateImage() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile image.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }
  // Sign up method
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate() || !_validateImage() )  {
      // If the form is invalid, do not proceed
      return;
    }
    setState(() => _isLoading = true);
    try {
      final String role = _isServiceProvider ? 'service_provider' : 'user';

      // Pass optional business details only for service providers
      String? businessName =
          _isServiceProvider ? _businessNameController : null;
      String? businessDetails =
          _isServiceProvider ? _businessDetailsController.text.trim() : null;

      await _authService.completeSignUpProcess(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(), // Pass the phone number
        profileImage: _selectedImage,
        role: role, // Pass the determined role
        // profileImage: _selectedImage,
        city: _selectedCity,
        businessName: businessName,
        businessDetails: businessDetails, // Pass the selected city
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful!')),
      );

      // Navigate to the login screen after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginM()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  List<String> cities = [];
  List<String> services = [
    'Plumber',
    'Painting',
    'Electrical Work',
    'Carpentry',
    'House Cleaning',
    'Babysitting',
    'Cooking/Chef'
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenSize.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      Image.asset(
                        'assets/logopng.png',
                        height: 3,
                        width: 3,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.orange,
                          backgroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : null,
                          child: _selectedImage == null
                              ? const Icon(Icons.person_add_alt, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            CustomTextFormField(
                              hintText: "Enter user name",
                              controller: _nameCtrl,
                              prefixIcon: const Icon(Icons.person),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              hintText: "Email",
                              controller: _emailCtrl,
                              prefixIcon: const Icon(Icons.email),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              hintText: "Password",
                              controller: _passwordCtrl,
                              prefixIcon: const Icon(Icons.lock),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 6) {
                                  return 'Password should be at least 6 characters';
                                }
                                return null;
                              },
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              hintText: "Phone Number",
                              controller: _phoneCtrl,
                              prefixIcon: const Icon(Icons.phone),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your phone number';
                                }

                                final cleanedValue = value.trim().replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

                                print("Debug: Cleaned Value = $cleanedValue");

                                if (!RegExp(r'^(0\d{10}|92\d{10})$').hasMatch(cleanedValue)) {
                                  return 'Phone number must start with 0 or 92 and have valid length';
                                }

                                return null;
                              },
                              keyboardType: TextInputType.phone,
                            ),


                            const SizedBox(height: 15),
                            isLoading
                                ? const CircularProgressIndicator()
                                : DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Select City',
                                      prefixIcon: Icon(Icons.location_city),
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedCity,
                                    isExpanded: true,
                                    hint: const Text(
                                        "Select a city"),
                                    items: cities.map<DropdownMenuItem<String>>(
                                        (String city) {
                                      return DropdownMenuItem<String>(
                                        value: city,
                                        child: Text(city),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCity =
                                            newValue;
                                      });
                                    },
                                  ),
                            Row(
                              children: [

                                Checkbox(
                                  value: _isServiceProvider,
                                  onChanged: (value) {
                                    setState(() {
                                      _isServiceProvider = value!;
                                    });
                                  },
                                ),
                                Text('Are you a Service Provider?'),
                              ],
                            ),
                            SizedBox(height: 16),

                            if (_isServiceProvider) ...[
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select your Service',
                                  prefixIcon: Icon(Icons.work),
                                  border: OutlineInputBorder(),
                                ),
                                value: _businessNameController,
                                items: services.map((service) {
                                  return DropdownMenuItem<String>(
                                    value: service,
                                    child: Text(service),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _businessNameController = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'What Service You provide';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              CustomTextFormField(
                                controller: _businessDetailsController,
                                hintText: "Discribe you service",
                                prefixIcon: Icon(Icons.description),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your business details';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              const SizedBox(height: 15),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const MyTextt(text: "Already have an account?"),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const LoginM()),
                                    );
                                  },
                                  child: const MyTextt(
                                    text: "Log In",
                                    color: Colors.blue,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyElevatedButton(
                        text: _isLoading ? "Signing Up..." : "Sign Up",
                        onPressed: () {
                          _isLoading ? null : _signUp();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
